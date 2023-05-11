import 'dart:io';

void clearConsole() {
  if (Platform.isWindows) {
    // Limpa o console no Windows
    Process.runSync('cls', [], runInShell: true);
  } else {
    // Limpa o console em sistemas Unix (Linux, macOS)
    print('\x1B[2J\x1B[0;0H');
  }
}

void main() {
  do {
    var dependencies = <String, List<String>>{};
    List<String?> dependenciesList = [];
    try {
      stdout.write('Quantidade de dependências: ');
      int numDependencies = int.parse(stdin.readLineSync()!);

      for (int i = 0; i < numDependencies; i++) {
        stdout.write('Informe a dependência ${i + 1}º: ');
        dependenciesList.add(stdin.readLineSync());
      }
    } catch (e) {
      print('Informações inseridas estão incorretas! \n$e');
      continue;
    }

    for (var dependency in dependenciesList) {
      try {
        stdout.write('Quantidade de dependências dependentes de $dependency: ');
        int numDependents = int.parse(stdin.readLineSync()!);

        var dependents = <String>[];

        for (int j = 0; j < numDependents; j++) {
          stdout.write(
              'Informe a dependência dependente ${j + 1} de $dependency: ');
          String? dependent = stdin.readLineSync();
          dependents.add(dependent!);
        }

        dependencies[dependency!] = dependents;
      } catch (e) {
        print('Informações inseridas estão incorretas! \n$e');
        continue;
      }
    }

    try {
      var resolver = DependencyResolver(dependencies);
      var order = resolver.getDependencyOrder();
      print('Ordem de instalação das Dependências:');
      for (var dependency in order) {
        print(dependency);
      }
    } catch (e) {
      print(e);
    }

    stdout.write(
        '\nDeseja fazer outro teste? (Digite "s" para sim, ou qualquer outra tecla para sair) ');
  } while (stdin.readLineSync()?.toLowerCase() == 's');
}

class DependencyResolver {
  Map<String, List<String>> dependencies;

  DependencyResolver(this.dependencies);

  List<String> getDependencyOrder() {
    var visited = <String>{};
    var order = <String>[];

    for (var dependency in dependencies.keys) {
      if (!visited.contains(dependency)) {
        _visitDependency(dependency, visited, order);
      }
    }

    return order;
  }

  void _visitDependency(
      String dependency, Set<String> visited, List<String> order) {
    visited.add(dependency);

    if (dependencies.containsKey(dependency)) {
      for (var dependent in dependencies[dependency]!) {
        if (!visited.contains(dependent)) {
          _visitDependency(dependent, visited, order);
        }
      }
    }

    order.add(dependency);
  }
}
