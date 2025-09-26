"use client";
import {useEffect, useState} from "react";
import {loadYMaps3, YMaps3Modules} from "../lib/ymaps";
import {Geometry} from "@yandex/ymaps3-types/imperative/YMapFeature/types";
import {LngLat} from "ymaps3";


function getCenter(geom: Geometry): LngLat {
    let verts: LngLat[] = [[0.0, 0.0]];
    switch (geom.type) {
        case "Polygon":
            verts = geom.coordinates[0];
            break;
        case "MultiPolygon":
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            verts = geom.coordinates.flatMap((poly: any) => poly[0]);
            break;
    }
    let sumX = 0,
        sumY = 0;
    for (const [x, y] of verts) {
        sumX += x;
        sumY += y;
    }
    const n = verts.length;
    return n ? ([sumX / n, sumY / n] as LngLat) : ([0, 0] as LngLat);
}

export default function DemoMap() {
    const [YMapComponents, setYMapComponents] = useState<YMaps3Modules | null>(null);
    const [polygonGeom, setPolygonGeom] = useState<Geometry | null>(null);
    const [addressCoords, setAddressCoords] = useState<LngLat | null>(null);
    const [searchValue, setSearchValue] = useState("");

    useEffect(() => {
        loadYMaps3().then(setYMapComponents);
    }, []);

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        try {
            const text = await file.text();
            const json = JSON.parse(text) as Geometry;

            if (json.type !== "Polygon" && json.type !== "MultiPolygon") {
                alert("Файл должен содержать Polygon или MultiPolygon");
                return;
            }

            setPolygonGeom(json);
        } catch (err) {
            console.error("Ошибка чтения файла:", err);
            alert("Не удалось прочитать JSON");
        }
    };

    const handleSearch = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!searchValue.trim()) return;

        try {
            const response = await fetch(
                `https://geocode-maps.yandex.ru/1.x/?apikey=ВАШ_API_KEY&format=json&geocode=${encodeURIComponent(
                    searchValue
                )}`
            );
            const data = await response.json();

            const pos =
                data.response.GeoObjectCollection.featureMember[0]?.GeoObject?.Point?.pos;
            if (!pos) {
                alert("Адрес не найден");
                return;
            }

            const [lon, lat] = pos.split(" ").map(Number);
            setAddressCoords([lon, lat] as LngLat);
        } catch (err) {
            console.error("Ошибка поиска адреса:", err);
            alert("Ошибка при обращении к геокодеру");
        }
    };

    if (!YMapComponents) return <div>Загрузка карты...</div>;

    const {
        YMap,
        YMapDefaultSchemeLayer,
        YMapFeature,
        YMapDefaultFeaturesLayer,
        YMapMarker,
    } = YMapComponents;

    const center: LngLat =
        polygonGeom != null
            ? getCenter(polygonGeom)
            : addressCoords != null
                ? addressCoords
                : ([37.6173, 55.7558] as LngLat);

    return (
        <div className="flex justify-center items-center w-screen h-screen relative">
            <div className="flex flex-col justify-center items-center w-screen h-screen relative">
                <div className="w-full h-full">
                    <YMap
                        location={{
                            center,
                            zoom: polygonGeom ? 17 : addressCoords ? 15 : 10,
                        }}
                        mode="vector"
                    >
                        <YMapDefaultSchemeLayer/>
                        <YMapDefaultFeaturesLayer/>

                        {polygonGeom && (
                            <YMapFeature
                                geometry={polygonGeom}
                                style={{
                                    fill: "#00FF0088",
                                    stroke: [{color: "#00FF00", width: 2}],
                                }}
                            />
                        )}

                        {addressCoords && (
                            <YMapMarker coordinates={addressCoords}>
                                <div className="bg-red-500 w-4 h-4 rounded-full border-2 border-white"/>
                            </YMapMarker>
                        )}
                    </YMap>
                </div>

                {/* Панель инструментов */}
                <div className="absolute top-4 left-4 bg-white p-3 rounded shadow flex flex-col gap-3">
                    <label className="flex flex-col gap-2 cursor-pointer">
                        <span className="text-sm font-medium">Загрузить JSON с полигоном:</span>
                        <input
                            type="file"
                            accept=".json"
                            className="border p-1"
                            onChange={handleFileUpload}
                        />
                    </label>

                    <form onSubmit={handleSearch} className="flex gap-2">
                        <input
                            type="text"
                            value={searchValue}
                            onChange={(e) => setSearchValue(e.target.value)}
                            placeholder="Введите адрес..."
                            className="border p-1 flex-1"
                        />
                        <button
                            type="submit"
                            className="px-3 py-1 bg-blue-500 text-white rounded"
                        >
                            Найти
                        </button>
                    </form>
                </div>
            </div>
        </div>
    );
}
