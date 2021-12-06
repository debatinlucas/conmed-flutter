import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GerenciarConsultas());
}

class GerenciarConsultas extends StatelessWidget {
  const GerenciarConsultas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Gerenciamento de Consultas',
      home: MedicoPage(),
    );
  }
}

class MedicoPage extends StatefulWidget {
  const MedicoPage({Key? key}) : super(key: key);

  @override
  _MedicoPageState createState() => _MedicoPageState();
}

class _MedicoPageState extends State<MedicoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _crmController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _fixoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();

  final CollectionReference _medicos =
  FirebaseFirestore.instance.collection('medico');

  Future<void> _adicionarOuEditarMedico([DocumentSnapshot? documentSnapshot]) async {
    String action = 'adicionar';
    if (documentSnapshot != null) {
      action = 'editar';
      _nomeController.text = documentSnapshot['nome'];
      _crmController.text = documentSnapshot['crm'].toString();
      _logradouroController.text = documentSnapshot['logradouro'];
      _numeroController.text = documentSnapshot['numero'].toString();
      _cidadeController.text = documentSnapshot['cidade'];
      _ufController.text = documentSnapshot['uf'];
      _fixoController.text = documentSnapshot['fixo'];
      _celularController.text = documentSnapshot['celular'];
    } else {
      _nomeController.text = '';
      _crmController.text = '';
      _logradouroController.text = '';
      _numeroController.text = '';
      _cidadeController.text = '';
      _ufController.text = '';
      _fixoController.text = '';
      _celularController.text = '';
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  controller: _crmController,
                  decoration: const InputDecoration(
                    labelText: 'CRM',
                  ),
                ),
                TextField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(labelText: 'Logradouro'),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  controller: _numeroController,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                  ),
                ),
                TextField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                ),
                TextField(
                  controller: _ufController,
                  decoration: const InputDecoration(labelText: 'UF'),
                ),
                TextField(
                  controller: _fixoController,
                  decoration: const InputDecoration(labelText: 'Fixo'),
                ),
                TextField(
                  controller: _celularController,
                  decoration: const InputDecoration(labelText: 'Celular'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'adicionar' ? 'Adicionar' : 'Editar'),
                  onPressed: () async {
                    final String? nome = _nomeController.text;
                    final int? crm = int.tryParse(_crmController.text);
                    final String? logradouro = _logradouroController.text;
                    final int? numero = int.tryParse(_numeroController.text);
                    final String? cidade = _cidadeController.text;
                    final String? uf = _ufController.text;
                    final String? fixo = _fixoController.text;
                    final String? celular = _celularController.text;
                    String? mensagem = '';
                    if (nome != null && crm != null && logradouro != null &&
                        numero != null && cidade != null && uf != null &&
                        fixo != null && celular != null) {
                      if (action == 'adicionar') {
                        // Salva um novo médico no Firestore
                        await _medicos.add({"nome": nome, "crm": crm,
                          "logradouro": logradouro, "numero": numero,
                          "cidade": cidade, "uf": uf, "fixo": fixo,
                          "celular": celular});

                        mensagem = 'Médico Adicionado';
                      }

                      if (action == 'editar') {
                        // Atualiza o médico no Firestore pelo seu ID
                        await _medicos
                            .doc(documentSnapshot!.id)
                            .update({"nome": nome, "crm": crm,
                              "logradouro": logradouro, "numero": numero,
                              "cidade": cidade, "uf": uf, "fixo": fixo,
                              "celular": celular});

                        mensagem = 'Médico Editado';
                      }

                      // Limpa todos os campos
                      _nomeController.text = '';
                      _crmController.text = '';
                      _logradouroController.text = '';
                      _numeroController.text = '';
                      _cidadeController.text = '';
                      _ufController.text = '';
                      _fixoController.text = '';
                      _celularController.text = '';

                      Navigator.of(context).pop();
                      // Mostrar a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(mensagem))
                      );
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Por favor, informe todos os campos!',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          fontSize: 20.0
                      );
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Excluir o médico pelo ID
  Future<void> _excluirMedico(String medicoId) async {
    await _medicos.doc(medicoId).delete();

    // Mostrar a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Médico Excluído'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Consultas'),
      ),
      // Usando o StreamBuilder para exibir todos os médico da Firestore em
      // tempo real
      body: StreamBuilder(
        stream: _medicos.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['nome']),
                    subtitle: Text(documentSnapshot['crm'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Ícone para editar um médico da lista
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _adicionarOuEditarMedico(documentSnapshot)),
                          // Ícone para excluir um médico da lista
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                if (await confirm(
                                  context,
                                  title: Text('Confirmar Exclusão'),
                                  content: Text('Você deseja excluir o médico "' + documentSnapshot['nome'] + '"?'),
                                  textOK: Text('Sim'),
                                  textCancel: Text('Não'),
                                )) {
                                  _excluirMedico(documentSnapshot.id);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Ícone para dicionar um novo médico
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarOuEditarMedico(),
        child: const Icon(Icons.add),
      ),
    );
  }
}