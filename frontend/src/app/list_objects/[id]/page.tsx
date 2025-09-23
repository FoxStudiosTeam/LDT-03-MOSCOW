'use client';

import { Header } from "@/app/components/header";

interface Project {
    id: number;
    address: string;
    status: string;
    customer?: string;
    contractor?: string;
    inspector?: string;
    coordinates?: { x: number; y: number; z: number };
    mapUrl?: string;
}

const projects: Project[] = [
    {
        id: 1,
        address: "ул. Волковское шоссе, д. 12",
        status: "В работе",
        customer: "ГКУ МСК Представитель: Иванов И.И.",
        contractor: "ООО СтройГрад Исполнитель: Сидоров И.И.",
        inspector: "Петров П.П.",
        coordinates: { x: -123, y: 45, z: -999 },
        mapUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Openstreetmap_map.png/640px-Openstreetmap_map.png",
    },
];

export default function ObjectDetail() {
    return (
        <div className="flex justify-center min-h-screen bg-[#D0D0D0]">
            <Header />
            <main className="w-[60%] bg-white px-8 pt-2">
                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-xl font-semibold">Ваши объекты</h1>
                </div>

                <div className="flex gap-4 mb-6">
                    <button className="bg-red-700 text-white px-4 py-2 rounded-md">
                        В процессе
                    </button>
                    <button className="bg-red-700 text-white px-4 py-2 rounded-md">
                        Завершенные
                    </button>
                    <button className="bg-red-700 text-white px-4 py-2 rounded-md">
                        Создать новый
                    </button>
                </div>

                <div className="space-y-4">

                    <div
                        key={project.id}
                        className="border rounded-md p-4 bg-white shadow-sm"
                    >
                        <div
                            className="flex justify-between items-center cursor-pointer"
                            onClick={() => toggleProject(project.id)}
                        >
                            <div>
                                <p className="font-medium">{project.address}</p>
                                <p className="text-sm text-gray-600">
                                    Статус: {project.status}
                                </p>
                            </div>
                            <span className="text-xl">
                                {openProject === project.id ? "▲" : "▼"}
                            </span>
                        </div>

                        {openProject === project.id && (
                            <div className="mt-4 space-y-2 text-sm">
                                {project.customer && <p>Заказчик: {project.customer}</p>}
                                {project.contractor && <p>Подрядчик: {project.contractor}</p>}
                                {project.inspector && (
                                    <p>Ответственный инспектор: {project.inspector}</p>
                                )}
                                {project.mapUrl && (
                                    <img
                                        src={project.mapUrl}
                                        alt="Карта"
                                        className="w-full h-64 object-cover rounded-md"
                                    />
                                )}
                                {project.coordinates && (
                                    <p>
                                        Координаты: X: {project.coordinates.x}, Y:{" "}
                                        {project.coordinates.y}, Z: {project.coordinates.z}
                                    </p>
                                )}
                            </div>
                        )}
                    </div>
                </div>
            </main>
        </div>

    )
}