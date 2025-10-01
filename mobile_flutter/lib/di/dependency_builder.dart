import 'dependency_container.dart';

abstract class IDependencyBuilder {
  registerDependency(String token, Object value);
  T getDependency<T>(String token);
  IDependencyContainer build();
}


class DependencyBuilder implements IDependencyBuilder{
  final dependencies = <String, Object>{};

  @override
  IDependencyContainer build() {
    return DependencyContainer(dependencies);
  }

  @override
  registerDependency(String token, Object value) {
    dependencies[token] = value;
  }

  @override
  T getDependency<T>(String token) {
    return dependencies[token] as T;
  }

}