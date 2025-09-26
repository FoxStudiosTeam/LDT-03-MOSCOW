import { YMapReactContainer } from "@yandex/ymaps3-types/imperative/YMapReactContainer";
import { ReactifiedModule, Reactify } from "@yandex/ymaps3-types/reactify";
import React from "react";
import ReactDOM from "react-dom";

export type YMaps3Modules = ReactifiedModule<Record<string | symbol, unknown> & {
    __implReactifyOverride?: (reactify: Reactify) => object;
  } & typeof import("../../../node_modules/@yandex/ymaps3-types/index") & {
      YMapReactContainer: typeof YMapReactContainer;
  }>;


let _ymaps3Modules: YMaps3Modules | null = null;

export async function loadYMaps3(): Promise<YMaps3Modules> {
  if (_ymaps3Modules) {
    console.warn("YMaps3 already loaded");
    return _ymaps3Modules;
  }
  console.warn("YMaps3 loading...");

  if (typeof window === "undefined") throw new Error("YMaps3 can only load in browser");

  if (!("ymaps3" in window)) {
    await new Promise<void>((resolve) => {
      const check = () => ("ymaps3" in window ? resolve() : setTimeout(check, 50));
      check();
    });
  }

  await ymaps3.ready;

  const ymaps3React = await ymaps3.import("@yandex/ymaps3-reactify");
  const reactify = ymaps3React.reactify.bindTo(React, ReactDOM);
  _ymaps3Modules = reactify.module(ymaps3);
  return _ymaps3Modules
}