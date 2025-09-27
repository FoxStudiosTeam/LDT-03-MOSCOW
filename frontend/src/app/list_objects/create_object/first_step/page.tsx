'use client';

import { useEffect, useState } from "react";
import { loadYMaps3, YMaps3Modules } from "@/app/lib/ymaps";
import { Geometry } from "@yandex/ymaps3-types/imperative/YMapFeature/types";
import { LngLat } from "ymaps3";
import { Header } from "@/app/components/header";
import { useForm } from "react-hook-form";
import { FirstStepForm } from "@/models";
import { useUserStore } from "@/storage/userstore";
import {CreateObject} from "@/app/Api/Api";
import { useRouter } from "next/navigation";


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

export default function FirstStep() {
    const [message, setMessage] = useState<string>("");
    const userData = useUserStore((state) => state.userData);
    const router = useRouter();

    const { register, handleSubmit, setValue } = useForm<FirstStepForm>({
    });

    const onSubmit = async (data: FirstStepForm) => {
        if (!data || !userData) {
            setMessage("Повторите попытку");
            return;
        }

        try {
            const {success, message, result} = await CreateObject(data.address, data.polygon, userData.uuid);
            if (success && result) {
                console.log(result)
                localStorage.setItem("projectUuid", result);
                router.push("/list_objects/create_object/second_step");
            } else {
                setMessage(message || "Ошибка создания объекта");
            }
        } catch (error) {
            setMessage(`${error}`);
        }
    }

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

        if (!file.name.endsWith(".json")) {
            alert("Можно загружать только файлы с расширением .json");
            return;
        }

        try {
            const text = await file.text();
            setValue("polygon", text)
            const json = JSON.parse(text);

            if (typeof json !== "object" || !json.type || !json.coordinates) {
                alert("Файл должен быть корректным GeoJSON объектом");
                return;
            }

            if (json.type !== "Polygon" && json.type !== "MultiPolygon") {
                alert("Файл должен содержать Polygon или MultiPolygon");
                return;
            }

            const checkCoords = (coords: unknown): boolean => {
                if (!Array.isArray(coords)) return false;
                if (typeof coords[0] === "number" && typeof coords[1] === "number") {
                    return true;
                }
                return coords.every((c) => checkCoords(c));
            };

            if (!checkCoords(json.coordinates)) {
                alert("Неверный формат координат");
                return;
            }

            setPolygonGeom(json as Geometry);
        } catch (err) {
            console.error("Ошибка чтения файла:", err);
            alert("Не удалось прочитать JSON");
        }
    };

    const handleSearch = async () => {
        if (!searchValue.trim()) return;

        try {
            const response = await fetch(
                `https://geocode-maps.yandex.ru/1.x/?apikey=API_KEY&format=json&geocode=${encodeURIComponent(
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
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8">
                <form onSubmit={handleSubmit(onSubmit)} className="flex justify-center">
                    <div className="flex flex-col gap-5 w-[1000px] h-[600px] justify-center items-center relative">
                        <div className="w-full flex flex-row justify-between">
                            <p className="font-bold">Новый объект</p>
                            <p>Этап 1 из 2</p>
                        </div>
                        <div className="w-[45%] top-4 left-4 flex flex-row self-start gap-3">
                            <input
                                {...register('address')}
                                type="text"
                                value={searchValue}
                                onChange={(e) => setSearchValue(e.target.value)}
                                placeholder="Введите адрес..."
                                className="w-full flex-1 border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                            <button
                                type="button"
                                className="self-start bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg"
                                onClick={handleSearch}
                            >
                                Найти
                            </button>
                        </div>
                        <div className="w-full h-full">
                            <YMap
                                location={{
                                    center,
                                    zoom: polygonGeom ? 17 : addressCoords ? 15 : 10,
                                }}
                                mode="vector"
                            >
                                <YMapDefaultSchemeLayer />
                                <YMapDefaultFeaturesLayer />

                                {polygonGeom && (
                                    <YMapFeature
                                        geometry={polygonGeom}
                                        style={{
                                            fill: "#00FF0088",
                                            stroke: [{ color: "#00FF00", width: 2 }],
                                        }}
                                    />
                                )}

                                {addressCoords && (
                                    <YMapMarker coordinates={addressCoords}>
                                        <div className="bg-red-500 w-4 h-4 rounded-full border-2 border-white" />
                                    </YMapMarker>
                                )}
                            </YMap>
                        </div>

                        <div className="w-full flex flex-row self-start gap-2 items-center justify-between">
                            <div className="flex flex-row items-center gap-2 cursor-pointer">
                                <label htmlFor="coords" className="cursor-pointer">
                                    <span className="text-sm font-medium">Загрузить координаты в формате JSON</span>
                                </label>

                                <label htmlFor="coords" className="bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg cursor-pointer">
                                    Загрузить
                                </label>
                            </div>

                            <input
                                id={'coords'}
                                type="file"
                                accept=".json"
                                className="hidden"
                                onChange={handleFileUpload}
                            />

                            <input type="submit" value={"Далее"} className="bg-red-700 hover:bg-red-800 text-white px-6 py-2 rounded-lg"></input>
                        </div>

                        {message && <p className="w-full text-center text-red-600 pt-2">{message}</p>}
                    </div>
                </form>
            </main>
        </div>
    )
}