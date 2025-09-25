import { YMapReactContainer } from "@yandex/ymaps3-types/imperative/YMapReactContainer";
import { ReactifiedModule, Reactify } from "@yandex/ymaps3-types/reactify";
import React from "react";
import ReactDOM from "react-dom";
import { YMap, YMapDefaultSchemeLayer, YMapMarker, YMapDefaultFeaturesLayer } from "ymaps3";

export type YMaps3Modules = ReactifiedModule<Record<string | symbol, unknown> & {
    __implReactifyOverride?: (reactify: Reactify) => object;
  } & typeof import("r:/prog/LDT-03-MOSCOW/frontend/node_modules/@yandex/ymaps3-types/index") & {
      YMapReactContainer: typeof YMapReactContainer;
  }>;

export async function loadYMaps3() {
  if (typeof window === "undefined") return null;
  if (!("ymaps3" in window)) {
    await new Promise<void>((resolve, reject) => {
      const check = () => {
        if ("ymaps3" in window) resolve();
        else setTimeout(check, 50);
      };
      check();
    });
  }
  await ymaps3.ready;
  const ymaps3React = await ymaps3.import("@yandex/ymaps3-reactify");
  const reactify = ymaps3React.reactify.bindTo(React, ReactDOM);
  const modules : YMaps3Modules = reactify.module(ymaps3);
  return modules;
}
