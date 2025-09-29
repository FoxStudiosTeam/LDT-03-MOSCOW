abstract class IDependencyContainer {
   T getDependency<T>(String token);
}

class DependencyContainer implements IDependencyContainer {
  Map<String, Object> dependencies = <String, Object>{};

  DependencyContainer(this.dependencies);

  @override
  T getDependency<T>(String token) {
    return dependencies[token] as T;
  }
}