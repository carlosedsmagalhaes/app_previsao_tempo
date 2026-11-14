import 'package:flutter/material.dart';

import 'package:app_previsao_tempo/features/previsao/data/repositories/repositorio_previsoes.dart';
import 'package:app_previsao_tempo/features/previsao/models/cidade.dart';
import 'package:app_previsao_tempo/features/previsao/models/previsao_cidade.dart';
import 'package:app_previsao_tempo/features/previsao/models/previsao_salva.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/formatacao.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/widgets/fonte_dados.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/widgets/grafico_temperaturas.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/widgets/item_dia.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/widgets/mensagem_estado.dart';
import 'package:app_previsao_tempo/features/previsao/services/erro_consulta.dart';
import 'package:app_previsao_tempo/features/previsao/services/leitor_xml_cptec.dart';
import 'package:app_previsao_tempo/features/previsao/services/servico_cptec.dart';

class TelaPrevisao extends StatefulWidget {
  // A cidade escolhida na busca; o id dela vai na URL da previsão.
  final Cidade cidade;

  const TelaPrevisao({super.key, required this.cidade});

  @override
  State<TelaPrevisao> createState() => _TelaPrevisaoState();
}

class _TelaPrevisaoState extends State<TelaPrevisao> {
  final _servico = const ServicoCptec();
  final _repositorio = const RepositorioPrevisoes();

  PrevisaoCidade? _previsao;
  bool _carregando = true;
  String? _erro;
  String? _aviso; // Preenchido quando a tela mostra a previsão salva

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _aviso = null;
    });

    try {
      final xml = await _servico.baixarPrevisao(widget.cidade.id);
      final previsao = LeitorXmlCptec.lerPrevisao(xml);

      // Só guarda no SQLite uma previsão que tenha dias.
      if (previsao.dias.isNotEmpty) {
        await _salvar(xml);
      }

      if (!mounted) return;
      setState(() => _previsao = previsao);
    } on ErroConsulta catch (erro) {
      await _usarPrevisaoSalva(erro.mensagem);
    } catch (erro) {
      debugPrint('Erro inesperado na previsão: $erro');
      await _usarPrevisaoSalva('Não foi possível carregar a previsão.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Uma falha ao salvar não impede de mostrar a previsão recebida.
  Future<void> _salvar(String xml) async {
    try {
      await _repositorio.salvar(widget.cidade, xml);
    } catch (erro) {
      debugPrint('Não foi possível salvar a previsão: $erro');
    }
  }

  // Sem conexão ou com o serviço fora do ar: usa a última previsão salva.
  Future<void> _usarPrevisaoSalva(String motivo) async {
    PrevisaoSalva? salva;

    try {
      salva = await _repositorio.buscar(widget.cidade.id);
    } catch (erro) {
      debugPrint('Erro ao ler a previsão salva: $erro');
    }

    if (!mounted) return;

    if (salva == null) {
      setState(() => _erro = motivo);
      return;
    }

    try {
      final previsao = LeitorXmlCptec.lerPrevisao(salva.xml);
      final salvaEm = formatarDataHora(salva.salvoEm);
      setState(() {
        _previsao = previsao;
        _aviso = '$motivo\nMostrando a previsão salva em $salvaEm.';
      });
    } on ErroConsulta {
      setState(() => _erro = motivo);
    }
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    final erro = _erro;
    if (erro != null) {
      return MensagemEstado(
        icone: Icons.cloud_off,
        texto: erro,
        textoBotao: 'Tentar novamente',
        aoPressionar: _carregar,
      );
    }

    final previsao = _previsao;
    if (previsao == null || previsao.dias.isEmpty) {
      return MensagemEstado(
        icone: Icons.event_busy,
        texto: 'Não há previsão disponível para esta cidade no momento.',
        textoBotao: 'Atualizar',
        aoPressionar: _carregar,
      );
    }

    final aviso = _aviso;
    final atualizacao = previsao.atualizacao;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (aviso != null)
          Card(
            color: Colors.amber.shade100,
            child: ListTile(
              leading: const Icon(Icons.warning_amber),
              title: Text(aviso),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${previsao.nome} - ${previsao.uf}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                atualizacao == null
                    ? 'Data de atualização não informada'
                    : 'Atualizada pelo CPTEC/INPE em ${formatarData(atualizacao)}',
              ),
            ],
          ),
        ),
        GraficoTemperaturas(dias: previsao.dias),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 16, 4, 4),
          child: Text(
            'Previsão para os próximos dias',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // Todos os dias retornados pelo serviço.
        for (final dia in previsao.dias) ItemDia(dia: dia),
        const FonteDados(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cidade.nome),
        actions: [
          IconButton(
            tooltip: 'Atualizar previsão',
            onPressed: _carregando ? null : _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _construirConteudo(),
    );
  }
}
