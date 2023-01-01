import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/colors.dart';
import 'package:google_docs_clone/common/loader.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/repository/auth_repostitory.dart';
import 'package:google_docs_clone/repository/document_repository.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authResitoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);
    final token = ref.read(userProvider)!.token;
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId) =>
      Routemaster.of(context).push('/document/$documentId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalett.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDocument(ref, context),
            icon: const Icon(
              Icons.add,
              color: ColorPalett.black,
            ),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(
              Icons.logout,
              color: ColorPalett.red,
            ),
          ),
        ],
      ),
      body: FutureBuilder<ErrorModel?>(
        future: ref
            .watch(documentRepositoryProvider)
            .getDocuemnts(ref.watch(userProvider)!.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return Center(
            child: SizedBox(
              width: 600,
              child: ListView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  DocumentModel document = snapshot.data!.data[index];

                  return Container(
                    height: 50,
                    margin: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () => navigateToDocument(context, document.id),
                      child: Card(
                        elevation: 0,
                        child: Center(
                          child: Text(
                            document.title,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
