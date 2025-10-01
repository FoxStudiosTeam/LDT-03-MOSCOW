'use client';

import React, { useEffect, useRef, useState } from "react";
import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import { Header } from "@/app/components/header";
import { useForm } from "react-hook-form";
import { FirstStepForm } from "@/models";
import { useUserStore } from "@/storage/userstore";
import { CreateObject } from "@/app/Api/Api";
import { useRouter } from "next/navigation";
import { useAuthRedirect } from "@/lib/hooks/useAuthRedirect";

type PolygonGeoJSON = GeoJSON.Polygon | GeoJSON.MultiPolygon;

export default function FirstStep() {
    useAuthRedirect();
    const mapContainer = useRef<HTMLDivElement | null>(null);
    const mapRef = useRef<maplibregl.Map | null>(null);

    const [message, setMessage] = useState<string>("");
    const [polygonGeom, setPolygonGeom] = useState<PolygonGeoJSON | null>(null);

    const userData = useUserStore((state) => state.userData);
    const router = useRouter();

    const { register, handleSubmit, setValue } = useForm<FirstStepForm>();

    useEffect(() => {
        if (mapRef.current || !mapContainer.current) return;

        const map = new maplibregl.Map({
            container: mapContainer.current,
            style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            center: [37.6173, 55.7558],
            zoom: 10,
        });

        mapRef.current = map;

        return () => {
            map.remove();
            mapRef.current = null;
        };
    }, []);

    // отрисовка полигона
    useEffect(() => {
        if (!mapRef.current || !polygonGeom) return;

        const geoJsonFeature: GeoJSON.Feature<GeoJSON.Polygon | GeoJSON.MultiPolygon> = {
            type: "Feature",
            properties: {},
            geometry: polygonGeom,
        };

        const map = mapRef.current;
        const existingSource = map.getSource("polygon") as maplibregl.GeoJSONSource | undefined;

        if (existingSource && typeof existingSource.setData === "function") {
            existingSource.setData(geoJsonFeature);
        } else {
            if (!map.getSource("polygon")) {
                map.addSource("polygon", {
                    type: "geojson",
                    data: geoJsonFeature,
                });
            }

            if (!map.getLayer("polygon-fill")) {
                map.addLayer({
                    id: "polygon-fill",
                    type: "fill",
                    source: "polygon",
                    paint: {
                        "fill-color": "#00FF00",
                        "fill-opacity": 0.4,
                    },
                });
            }

            if (!map.getLayer("polygon-outline")) {
                map.addLayer({
                    id: "polygon-outline",
                    type: "line",
                    source: "polygon",
                    paint: {
                        "line-color": "#00FF00",
                        "line-width": 2,
                    },
                });
            }
        }

        let coords: number[][];
        if (polygonGeom.type === "Polygon") {
            coords = polygonGeom.coordinates[0];
        } else {
            coords = polygonGeom.coordinates[0][0];
        }

        if (coords.length > 0) {
            const first = coords[0] as maplibregl.LngLatLike;
            const bounds = coords.reduce(
                (b: maplibregl.LngLatBounds, c) => b.extend(c as maplibregl.LngLatLike),
                new maplibregl.LngLatBounds(first, first)
            );
            map.fitBounds(bounds, { padding: 40 });
        }
    }, [polygonGeom]);

    // проверка файла
    const isPolygonGeoJSON = (obj: unknown): obj is PolygonGeoJSON => {
        if (!obj || typeof obj !== "object") return false;
        const maybe = obj as { type?: unknown; coordinates?: unknown };
        if (maybe.type === "Polygon") return Array.isArray(maybe.coordinates);
        if (maybe.type === "MultiPolygon") return Array.isArray(maybe.coordinates);
        return false;
    };

    // загрузка файла полигона
    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (!file.name.toLowerCase().endsWith(".json")) {
            alert("Можно загружать только файлы с расширением .json");
            return;
        }

        try {
            const text = await file.text();
            const parsed = JSON.parse(text) as unknown;

            if (!isPolygonGeoJSON(parsed)) {
                alert("Файл должен содержать Polygon или MultiPolygon");
                return;
            }

            setValue("polygon", text);
            setPolygonGeom(parsed);
        } catch {
            alert("Не удалось прочитать JSON");
        }
    };

    // сабмит формы
    const onSubmit = async (data: FirstStepForm) => {
        if (!data || !userData) {
            setMessage("Повторите попытку");
            return;
        }

        // проверка адреса
        if (!data.address || data.address.trim() === "") {
            setMessage("Введите адрес");
            return;
        }

        // проверка полигона
        if (!polygonGeom) {
            setMessage("Необходимо загрузить полигон в формате JSON");
            return;
        }

        try {
            const res = await CreateObject(data.address, data.polygon);

            if (res && typeof res === "object" && "success" in res) {
                const { success, message: srvMessage, result } = res as {
                    success: boolean;
                    message?: string;
                    result?: string;
                };
                if (success && result) {
                    localStorage.setItem("projectUuid", result);
                    router.push("/list_objects/create_object/second_step");
                } else {
                    setMessage(srvMessage ?? "Ошибка создания объекта");
                }
            } else {
                setMessage("Непредвиденный ответ от сервера");
            }
        } catch (error) {
            const text = error instanceof Error ? error.message : String(error);
            setMessage(text);
        }
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-full max-w-[1200px] bg-white px-4 sm:px-6 md:px-8">
                <form onSubmit={handleSubmit(onSubmit)} className="flex justify-center">
                    <div className="flex flex-col gap-5 w-full h-auto min-h-[600px] justify-center items-center relative py-6">
                        <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                            <p className="font-bold">Новый объект</p>
                            <p>Этап 1 из 2</p>
                        </div>

                        <div className="w-full sm:w-[60%] flex flex-col sm:flex-row gap-3">
                            <input
                                {...register("address")}
                                type="text"
                                placeholder="Введите адрес"
                                className="w-full flex-1 border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>

                        <div className="w-full h-[300px] sm:h-[500px]">
                            <div
                                ref={mapContainer}
                                className="w-full h-full rounded-2xl shadow-lg"
                            />
                        </div>

                        <div className="w-full flex flex-col sm:flex-row gap-3 items-center justify-between">
                            <div className="flex flex-col sm:flex-row items-center gap-2 cursor-pointer">
                                <label htmlFor="coords" className="cursor-pointer">
                                    <span className="text-sm font-medium">
                                        Загрузить координаты в формате JSON
                                    </span>
                                </label>

                                <label
                                    htmlFor="coords"
                                    className="bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg cursor-pointer"
                                >
                                    Загрузить
                                </label>
                            </div>

                            <input
                                id={"coords"}
                                type="file"
                                accept=".json"
                                className="hidden"
                                onChange={handleFileUpload}
                            />

                            <button
                                type="submit"
                                className="self-end bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg sm:w-auto"
                            >
                                Далее
                            </button>
                        </div>

                        {message && (
                            <p className="w-full text-center text-red-600 pt-2">{message}</p>
                        )}
                    </div>
                </form>
            </main>
        </div>
    );
}
