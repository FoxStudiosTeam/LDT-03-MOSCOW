'use client';

import React, { useEffect, useMemo, useState } from "react";
import { Header } from "@/app/components/header";
import { Chart } from "react-google-charts";
import { useActionsStore, DataBlock as ZDataBlock, Item as ZItem, } from "@/storage/jobsStorage";
import { GetProjectSchedule } from "@/app/Api/Api";
import styles from "@/app/styles/variables.module.css";
import Link from "next/link";
import Image from "next/image";
import { useUserStore } from "@/storage/userstore";
import { useAuthRedirect } from "@/lib/hooks/useAuthRedirect";

type GanttRow = [
    string,              // Task ID
    string,              // Task Name
    string | null,       // Resource
    Date | null,         // Start Date
    Date | null,         // End Date
    number | null,       // Duration
    number,              // Percent Complete
    string | null,       // Dependencies
];

function parseDateFromString(dateStr: string | undefined | null): Date | null {
    if (!dateStr) return null;
    const parts = dateStr.split("-");
    if (parts.length !== 3) return null;
    const [y, m, d] = parts.map((p) => Number(p));
    if (Number.isNaN(y) || Number.isNaN(m) || Number.isNaN(d)) return null;
    return new Date(y, m - 1, d); // локальная дата без смещения
}

const chartHeader = [
    { type: "string", label: "ID задачи" },
    { type: "string", label: "Название задачи" },
    { type: "string", label: "Ресурс" },
    { type: "date", label: "Дата начала" },
    { type: "date", label: "Дата окончания" },
    { type: "number", label: "Длительность" },
    { type: "number", label: "Процент выполнения" },
    { type: "string", label: "Зависимости" },
] as const;


export default function GanttPage() {
    const isReady = useAuthRedirect();
    const dataBlocks = useActionsStore((s) => s.data);
    const addDataBlock = useActionsStore((s) => s.addDataBlock);
    const clearData = useActionsStore((s) => s.clearData);

    const [message, setMessage] = useState<string | null>(null);
    const [isEmpty, setIsEmpty] = useState(false);

    const uuid = localStorage.getItem("projectUuid");

    const userData = useUserStore((state) => state.userData);
    const [userRole, setUserRole] = useState<string | null>(null);

    useEffect(() => {
        if (!userData) return;
        setUserRole(userData?.role);
    }, [userData])

    useEffect(() => {
        if (!isReady) return;
        async function loadData() {
            try {
                if (!uuid) {
                    setMessage("Ошибка: projectUuid не найден в localStorage");
                    return;
                }

                const { success, message: respMessage, result } = await GetProjectSchedule(uuid);

                if (success && result && Array.isArray(result.data)) {
                    if (result.data.length > 0) {
                        clearData();
                        result.data.forEach((block: ZDataBlock) => {
                            addDataBlock({
                                uuid: block.uuid,
                                title: block.title,
                                items: block.items ?? [],
                            });
                        });
                        setIsEmpty(false);
                        setMessage(null);
                    } else {
                        clearData();
                        setIsEmpty(true);
                        setMessage(null);
                    }
                } else if (!success && respMessage === "not found project_schedule") {
                    clearData();
                    setIsEmpty(true);
                } else {
                    setMessage(respMessage || "Ошибка загрузки этапов");
                }
            } catch (error) {
                console.error(error);
                setMessage(String(error));
            }
        }

        loadData();
    }, [addDataBlock, clearData, isReady, uuid]);

    const chartRows: GanttRow[] = useMemo(() => {
        const rows: GanttRow[] = [];
        let counter = 0;

        dataBlocks.forEach((block) => {
            const blockStart = parseDateFromString(block.start_date);
            const blockEnd = parseDateFromString(block.end_date);

            if (blockStart && blockEnd) {
                rows.push([
                    `stage-${counter++}`,
                    block.title,
                    "stage",
                    blockStart,
                    blockEnd,
                    null,
                    0,
                    null,
                ]);
            }

            (block.items ?? []).forEach((item: ZItem) => {
                const itemStart = parseDateFromString(item.start_date);
                const itemEnd = parseDateFromString(item.end_date);
                if (!itemStart || !itemEnd) return;

                rows.push([
                    `sub-${counter++}`,
                    "— " + item.title,
                    "substage",
                    itemStart,
                    itemEnd,
                    null,
                    item.is_completed ? 100 : 0,
                    null,
                ]);
            });
        });

        return rows;
    }, [dataBlocks]);

    const chartData = useMemo(() => {
        return [chartHeader, ...chartRows];
    }, [chartRows]);

    const chartOptions = {
        gantt: {
            trackHeight: 28,
            labelMaxWidth: 300,
            sortTasks: false,
            palette: [
                {
                    color: "#1E3A8A",
                    dark: "#162D6A",
                    light: "#3B82F6",
                },
                {
                    color: "#10B981",
                    dark: "#059669",
                    light: "#6EE7B7",
                },
            ],
        },
    };


    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 flex flex-col items-center gap-4">
                <div className="self-start">
                    <Link
                        href={`/list_objects/${uuid}`}
                        className="flex flex-row gap-2 items-center"
                    >
                        <Image
                            src={"/backArrow.svg"}
                            alt="Вернуться"
                            height={15}
                            width={30}
                        />
                        <span>Вернуться</span>
                    </Link>
                </div>
                <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                    <p className="font-bold">Диаграмма Ганта</p>
                </div>

                <div className="w-full overflow-x-scroll">
                    {dataBlocks.length > 0 ? (
                        <Chart
                            chartType="Gantt"
                            chartLanguage="ru"
                            width="100%"
                            height="520px"
                            data={chartData}
                            options={chartOptions}
                            loader={<div className="py-8 text-center">Загрузка диаграммы...</div>}
                        />
                    ) : isEmpty ? (
                        <p className="text-center text-gray-500 py-4">Данных пока нет</p>
                    ) : (
                        <p className="text-center text-gray-500 py-4">Загрузка...</p>
                    )}
                </div>

                <div className="w-full flex justify-end gap-4">
                    {userRole === 'customer' ? (
                        <Link href={"/gant/edit"} className={`text-center self-end min-w-[250px] ${styles.mainButton}`}>
                            Изменить
                        </Link>
                    ) : null}
                </div>

                {message && <p className="w-full text-center text-red-600 pt-2">{message}</p>}
            </main>
        </div>
    );
}
