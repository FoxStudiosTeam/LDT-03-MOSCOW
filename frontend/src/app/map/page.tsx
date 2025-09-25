"use client";
import { useEffect, useRef, useState } from "react";
import { loadYMaps3, YMaps3Modules } from "../lib/ymaps";
import { Geometry } from "@yandex/ymaps3-types/imperative/YMapFeature/types";
import { LngLat, PolygonGeometry } from "ymaps3";
import { Reactify } from "@yandex/ymaps3-types/reactify";
import { POLYS } from "../lib/polys";

function getCenter(geom: Geometry) : LngLat {
  let verts = [[0.0, 0.0] as LngLat]
  switch (geom.type) {
    case "Polygon":
      verts = geom.coordinates[0];
      break; 
    case "MultiPolygon": {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      verts = geom.coordinates.flatMap((poly: any) => poly[0]);
      break; 
    }
  }
  let sumX = 0, sumY = 0;
  console.log(verts)
  for (const [x, y] of verts) {
    sumX += x;
    sumY += y;
  }

  const n = verts.length;
  return n ? [sumX / n, sumY / n] : [0, 0];
}

function getFirst(geom: Geometry) : LngLat {
  switch (geom.type) {
    case "Polygon":
      return geom.coordinates[0][0];
    case "MultiPolygon": {
      return geom.coordinates[0][0][0];
    }
  }
  return [0, 0];
}

export default function DemoMap() {
  const [YMapComponents, setYMapComponents] = useState<YMaps3Modules | null>(null);
  const [currentPoly, setCurrentPoly] = useState(0);

  useEffect(() => {
    loadYMaps3().then(setYMapComponents);
  }, []);

  if (!YMapComponents) return <div>Loading map...</div>;
  // ymaps3.strictMode = true;


  const {
    YMap,
    YMapDefaultSchemeLayer,
    YMapFeature,
    YMapDefaultFeaturesLayer,
    YMapListener,
  } = YMapComponents;

  const polygonCoords = POLYS[currentPoly] as Geometry;
  const center = getCenter(polygonCoords);
  // no Reactify (since its hook and my loading strategy due to impossibility to await script loading in next) 
  // so every update one of components cause the whole map to rerender :(
  return (
    <div className="flex justify-center items-center w-screen h-screen relative">
      <div className="flex flex-col justify-center items-center w-screen h-screen relative">
      <div className="w-full h-full">
        <YMap location={{ center: center, zoom: 18 }} mode="vector">
          <YMapDefaultSchemeLayer />
          <YMapDefaultFeaturesLayer />
          <YMapFeature
            geometry={polygonCoords}
            style={{
              fill: "#00FF0088",
              stroke: [{ color: "#00FF00", width: 2 }]
            }}
          />
          {/* <YMapListener onUpdate={(e) => console.log(e)} /> */}
        </YMap>
      </div>

      <div className="absolute top-4 left-4 flex gap-2">
        {POLYS.map((_, idx) => (
          /*
            !!!!!! USE YANDEX MAP BUTTONS !!!!!
          */
          <button
            key={idx}
            className={`px-2 py-1 border-[2px] border-gray-400 rounded-3xl ${idx === currentPoly ? "bg-gray-200" : "bg-white"}`}
            onClick={() => setCurrentPoly(idx)}
          >
            Polygon {idx + 1}
          </button>
        ))}
      </div>
    </div>
    </div>
  );
}
