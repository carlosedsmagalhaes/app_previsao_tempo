import 'package:flutter/material.dart';

import 'package:app_previsao_tempo/features/previsao/data/repositories/repositorio_previsoes.dart';
import 'package:app_previsao_tempo/features/previsao/models/cidade.dart';
import 'package:app_previsao_tempo/features/previsao/models/previsao_salva.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/screens/tela_previsao.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/widgets/fonte_dados.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/widgets/mensagem_estado.dart';
import 'package:app_previsao_tempo/features/previsao/services/erro_consulta.dart';
import 'package:app_previsao_tempo/features/previsao/services/servico_cptec.dart';

class TelaBusca extends StatefulWidget {
  const TelaBusca({super.key});

  @override
  State<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends State<TelaBusca> {
  final _servico = const ServicoCptec();
  final _repositorio = const RepositorioPrevisoes();
  final _controlador = TextEditingController();

  bool _buscando = false;
  String? _avisoCampo; // Erro de preenchimento, mostrado no próprio campo
  String? _erro; // Erro da consulta (conexão, serviço, resposta inválida)
  String? _termoBuscado; // null = nenhuma busca feita ainda
  List<Cidade> _resultados = [];
  List<PrevisaoSalva> _recentes = [];

  @override
  void initState() {
    super.initState();
    _carregarRecentes();
  }

  // As cidades recentes vêm do SQLite. Se a leitura falhar, a busca
  // continua funcionando normalmente, apenas sem a lista.
  Future<void> _carregarRecentes() async {
    try {
      final recentes = await _repositorio.listarRecentes();
      if (!mounted) return;
      setState(() => _recentes = recentes);
    } catch (erro) {
      debugPrint('Erro ao ler as cidades recentes: $erro');
    }
  }

  Future<void> _buscar() async {
    final nome = _controlador.text.trim();

    if (nome.length < 2) {
      setState(() => _avisoCampo = 'Digite pelo menos 2 letras.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _buscando = true;
      _avisoCampo = null;
      _erro = null;
    });

    try {
      final cidades = await _servico.buscarCidades(nome);
      if (!mounted) return;
      setState(() {
        _resultados = cidades;
        _termoBuscado = nome;
      });
    } on ErroConsulta catch (erro) {
      if (!mounted) return;
      setState(() => _erro = erro.mensagem);
    } catch (erro) {
      debugPrint('Erro inesperado na busca: $erro');
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível buscar as cidades.');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  void _limparBusca() {
    _controlador.clear();
    setState(() {
      _termoBuscado = null;
      _resultados = [];
      _erro = null;
      _avisoCampo = null;
    });
  }

  Future<void> _abrirPrevisao(Cidade cidade) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TelaPrevisao(cidade: cidade),
      ),
    );

    // Ao voltar, a cidade consultada pode ter entrado nas recentes.
    await _carregarRecentes();
  }

  Widget _construirConteudo() {
    if (_buscando) {
      return const Center(child: CircularProgressIndicator());
    }

    final erro = _erro;
    if (erro != null) {
      return MensagemEstado(
        icone: Icons.wifi_off,
        texto: erro,
        textoBotao: 'Tentar novamente',
        aoPressionar: _buscar,
      );
    }

    // Antes de qualquer busca: mostra as cidades consultadas recentemente.
    if (_termoBuscado == null) {
      if (_recentes.isEmpty) {
        return const MensagemEstado(
          icone: Icons.location_city,
          texto: 'Pesquise uma cidade para ver a previsão do tempo.',
        );
      }

      return ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Consultadas recentemente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (final salva in _recentes)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(salva.cidade.nome),
              subtitle: Text('Estado: ${salva.cidade.uf}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _abrirPrevisao(salva.cidade),
            ),
        ],
      );
    }

    if (_resultados.isEmpty) {
      return MensagemEstado(
        icone: Icons.search_off,
        texto: 'Nenhuma cidade encontrada para "$_termoBuscado".\n'
            'Confira o nome e tente novamente.',
      );
    }

    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final cidade = _resultados[index];
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(cidade.nome),
          subtitle: Text('Estado: ${cidade.uf}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _abrirPrevisao(cidade),
        );
      },
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previsão do Tempo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controlador,
                    decoration: InputDecoration(
                      labelText: 'Nome da cidade',
                      hintText: 'Ex.: Jacareí',
                      errorText: _avisoCampo,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Limpar',
                        onPressed: _limparBusca,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FilledButton(
                    onPressed: _buscando ? null : _buscar,
                    child: const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _construirConteudo()),
          const FonteDados(),
        ],
      ),
    );
  }
}
