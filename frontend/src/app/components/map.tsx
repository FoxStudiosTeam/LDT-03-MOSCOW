"use client";

import { useEffect, useRef } from "react";
import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

interface ProjectMapProps {
    polygon: string; // JSON строка полигона с сервера
}

export function ProjectMap({ polygon }: ProjectMapProps) {
    const mapContainer = useRef<HTMLDivElement | null>(null);
    const mapRef = useRef<maplibregl.Map | null>(null);

    useEffect(() => {
        if (!mapContainer.current || mapRef.current) return;

        const map = new maplibregl.Map({
            container: mapContainer.current,
            style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            center: [37.6173, 55.7558],
            zoom: 10,
            interactive: true,
        });

        mapRef.current = map;

        return () => {
            map.remove();
            mapRef.current = null;
        };
    }, []);

    useEffect(() => {
        if (!mapRef.current) return;
        let parsed: GeoJSON.Polygon | GeoJSON.MultiPolygon;

        try {
            parsed = JSON.parse(polygon);
        } catch {
            return;
        }

        const map = mapRef.current;

        const addPolygonToMap = () => {
            const geoJsonFeature: GeoJSON.Feature<GeoJSON.Polygon | GeoJSON.MultiPolygon> = {
                type: "Feature",
                properties: {},
                geometry: parsed,
            };

            if (!map.getSource("polygon")) {
                map.addSource("polygon", { type: "geojson", data: geoJsonFeature });

                map.addLayer({
                    id: "polygon-fill",
                    type: "fill",
                    source: "polygon",
                    paint: { "fill-color": "#00FF00", "fill-opacity": 0.4 },
                });

                map.addLayer({
                    id: "polygon-outline",
                    type: "line",
                    source: "polygon",
                    paint: { "line-color": "#00FF00", "line-width": 2 },
                });
            } else {
                (map.getSource("polygon") as maplibregl.GeoJSONSource).setData(geoJsonFeature);
            }

            // Масштабирование под bounds
            let coords: number[][];
            if (parsed.type === "Polygon") coords = parsed.coordinates[0];
            else coords = parsed.coordinates[0][0];

            if (coords.length > 0) {
                const first = coords[0] as maplibregl.LngLatLike;
                const bounds = coords.reduce(
                    (b: maplibregl.LngLatBounds, c) => b.extend(c as maplibregl.LngLatLike),
                    new maplibregl.LngLatBounds(first, first)
                );
                map.fitBounds(bounds, { padding: 10 });
            }
        };

        if (map.isStyleLoaded()) {
            addPolygonToMap();
        } else {
            map.on("load", addPolygonToMap);
            return () => {
                map.off("load", addPolygonToMap);
            };
        }
    }, [polygon]);


    return <div ref={mapContainer} className="w-full h-[400px] rounded shadow" />;
}
