'use client';

import { useEffect, useRef, useState } from "react";
import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import { Header } from "@/app/components/header";
import { useForm } from "react-hook-form";
import { FirstStepForm } from "@/models";
import { useUserStore } from "@/storage/userstore";
import { CreateObject } from "@/app/Api/Api";
import { useRouter } from "next/navigation";

type PolygonGeoJSON = {
    type: "Polygon" | "MultiPolygon";
    coordinates: any;
};

export default function FirstStep() {
    const mapContainer = useRef<HTMLDivElement | null>(null);
    const mapRef = useRef<maplibregl.Map | null>(null);

    const [message, setMessage] = useState<string>("");
    const [polygonGeom, setPolygonGeom] = useState<PolygonGeoJSON | null>(null);
    const [addressCoords, setAddressCoords] = useState<[number, number] | null>(null);
    const [searchValue, setSearchValue] = useState("");

    const userData = useUserStore((state) => state.userData);
    const router = useRouter();

    const { register, handleSubmit, setValue } = useForm<FirstStepForm>();

    // инициализация карты
    useEffect(() => {
        if (mapRef.current || !mapContainer.current) return;

        mapRef.current = new maplibregl.Map({
            container: mapContainer.current,
            style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            center: [37.6173, 55.7558],
            zoom: 10,
        });
    }, []);

    // отрисовка полигона
    useEffect(() => {
        if (!mapRef.current || !polygonGeom) return;

        if (mapRef.current.getSource("polygon")) {
            (mapRef.current.getSource("polygon") as maplibregl.GeoJSONSource).setData(
                polygonGeom as any
            );
        } else {
            mapRef.current.addSource("polygon", {
                type: "geojson",
                data: polygonGeom as any,
            });
            mapRef.current.addLayer({
                id: "polygon-fill",
                type: "fill",
                source: "polygon",
                paint: {
                    "fill-color": "#00FF00",
                    "fill-opacity": 0.4,
                },
            });
            mapRef.current.addLayer({
                id: "polygon-outline",
                type: "line",
                source: "polygon",
                paint: {
                    "line-color": "#00FF00",
                    "line-width": 2,
                },
            });
        }

        // центрируем карту на полигон
        const coords =
            polygonGeom.type === "Polygon"
                ? polygonGeom.coordinates[0]
                : polygonGeom.coordinates[0][0];
        const bounds = coords.reduce(
            (b: maplibregl.LngLatBounds, [lng, lat]: [number, number]) =>
                b.extend([lng, lat]),
            new maplibregl.LngLatBounds(coords[0], coords[0])
        );
        mapRef.current.fitBounds(bounds, { padding: 40 });
    }, [polygonGeom]);

    // отрисовка маркера адреса
    useEffect(() => {
        if (!mapRef.current || !addressCoords) return;

        new maplibregl.Marker({ color: "red" })
            .setLngLat(addressCoords)
            .addTo(mapRef.current);

        mapRef.current.flyTo({ center: addressCoords, zoom: 15 });
    }, [addressCoords]);

    // поиск адреса
    const handleSearch = async () => {
        if (!searchValue.trim()) return;

        try {
            const response = await fetch(
                `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(
                    searchValue
                )}`
            );
            const data = await response.json();

            if (data.length > 0) {
                const { lon, lat } = data[0];
                setAddressCoords([parseFloat(lon), parseFloat(lat)]);
            } else {
                alert("Адрес не найден");
            }
        } catch (err) {
            console.error("Ошибка поиска:", err);
            alert("Ошибка при обращении к геокодеру");
        }
    };

    // загрузка файла полигона
    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (!file.name.endsWith(".json")) {
            alert("Можно загружать только файлы с расширением .json");
            return;
        }

        try {
            const text = await file.text();
            setValue("polygon", text);
            const json = JSON.parse(text);

            if (json.type !== "Polygon" && json.type !== "MultiPolygon") {
                alert("Файл должен содержать Polygon или MultiPolygon");
                return;
            }

            setPolygonGeom(json as PolygonGeoJSON);
        } catch (err) {
            console.error("Ошибка чтения файла:", err);
            alert("Не удалось прочитать JSON");
        }
    };

    // сабмит формы
    const onSubmit = async (data: FirstStepForm) => {
        if (!data || !userData) {
            setMessage("Повторите попытку");
            return;
        }

        try {
            const { success, message, result } = await CreateObject(
                data.address,
                data.polygon
            );
            if (success && result) {
                localStorage.setItem("projectUuid", result);
                router.push("/list_objects/create_object/second_step");
            } else {
                setMessage(message || "Ошибка создания объекта");
            }
        } catch (error) {
            setMessage(`${error}`);
        }
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-full max-w-[1200px] bg-white px-4 sm:px-6 md:px-8">
                <form
                    onSubmit={handleSubmit(onSubmit)}
                    className="flex justify-center"
                >
                    <div className="flex flex-col gap-5 w-full h-auto min-h-[600px] justify-center items-center relative py-6">
                        <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                            <p className="font-bold">Новый объект</p>
                            <p>Этап 1 из 2</p>
                        </div>

                        <div className="w-full sm:w-[60%] flex flex-col sm:flex-row gap-3">
                            <input
                                {...register("address")}
                                type="text"
                                value={searchValue}
                                onChange={(e) => setSearchValue(e.target.value)}
                                placeholder="Введите адрес..."
                                className="w-full flex-1 border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                            <button
                                type="button"
                                className="self-end bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg"
                                onClick={handleSearch}
                            >
                                Найти
                            </button>
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

                            <input
                                type="submit"
                                value={"Далее"}
                                className="self-end bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg sm:w-auto"
                            />
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
