import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoPrevisoes {
  static const _nomeArquivo = 'previsoes.db';
  static const _versao = 1;

  // Guarda a abertura para reutilizar a mesma conexão.
  static Future<Database>? _conexao;

  static Future<Database> obter() {
    return _conexao ??= _abrir();
  }

  static Future<Database> _abrir() async {
    try {
      final pasta = await getDatabasesPath();

      return await openDatabase(
        p.join(pasta, _nomeArquivo),
        version: _versao,
        // Executado apenas quando o banco ainda não existe.
        onCreate: (db, version) async {
          // Uma linha por cidade: a última previsão recebida dela.
          await db.execute('''
            CREATE TABLE previsoes_salvas (
              cidade_id INTEGER PRIMARY KEY,
              nome TEXT NOT NULL,
              uf TEXT NOT NULL,
              xml TEXT NOT NULL,
              salvo_em TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (erro) {
      // Permite uma nova tentativa na próxima chamada de obter().
      _conexao = null;
      rethrow;
    }
  }
}
