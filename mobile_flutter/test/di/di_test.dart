import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/di/dependency_builder.dart';

abstract class SomeA {
  String some();
}

class SomeAImpl implements SomeA {
  @override
  String some() {
    return "someA";
  }
}

class SomeAImplB implements SomeA {
  @override
  String some() {
    return "someAImplB";
  }
}



void main() {
  test("Di builders Tests", (){
      var builder = DependencyBuilder();
      builder.registerDependency("SomeA", SomeAImpl());
      builder.registerDependency("SomeB", SomeAImplB());
      var container = builder.build();

      expect(container.getDependency<SomeA>("SomeA").some(), "someA");
      expect(container.getDependency<SomeA>("SomeB").some(), "someAImplB");
  });
}