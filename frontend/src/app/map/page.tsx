"use client";
import { useEffect, useState } from "react";
import { loadYMaps3, YMaps3Modules } from "../lib/ymaps";

export default function DemoMap() {
  const [YMapComponents, setYMapComponents] = useState<YMaps3Modules | null>(null);

  useEffect(() => {
    loadYMaps3().then(setYMapComponents);
  }, []);

  if (!YMapComponents) return <div>Loading map...</div>;

  const { YMap, YMapDefaultSchemeLayer, YMapMarker, YMapDefaultFeaturesLayer } = YMapComponents;

  return (
    <div className="bg-red-950 w-screen h-screen flex items-center justify-center">
      <div className="bg-red-950 w-screen h-screen flex relative items-center justify-center">
      <div className="w-[500px] h-[500px] shadow-2xl">
        <YMap location={{center: [37.588144, 55.733842], zoom: 9}} mode="vector">
          <YMapDefaultSchemeLayer />
          <YMapDefaultFeaturesLayer />
          <YMapMarker coordinates={[37.588144, 55.733842]} draggable={true}>
            <section>
              <h1>You can drag this header</h1>
            </section>
          </YMapMarker>
        </YMap>
      </div>
    </div>
    </div>
  );
}
