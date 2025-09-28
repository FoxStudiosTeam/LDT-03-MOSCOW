'use client';

import { Header } from "@/app/components/header";
import React, { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { Getkpgz, GetMeasurement, GetWorkCategories } from "@/app/Api/Api";
import { Kpgz, Measurement, Works } from "@/models";

interface SubJob {
    title: string;
    volume: number;
    unitOfMeasurement: string;
    startDate: string;
    endDate: string;
}

export default function AddSubjobs() {
    const [tableData, setTableData] = useState<SubJob[]>([{
        title: '',
        volume: 0,
        unitOfMeasurement: '',
        startDate: '',
        endDate: '',
    }]);
    const router = useRouter();
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');
    const [works, setWorks] = useState<Works[]>([]);
    const [measurement, setMeasurement] = useState<Measurement[]>([]);
    const [kpgz, setkpgz] = useState<Kpgz[]>([]);
    const [selectedWork, setSelectedWork] = useState<Works | null>(null);
    const [editingCell, setEditingCell] = useState<{ row: number; col: keyof SubJob } | null>(null);
    const inputRef = useRef<HTMLInputElement | HTMLTextAreaElement | null>(null);
    const [messages, setMessages] = useState<string[]>([]);



    useEffect(() => {
        if (inputRef.current) {
            inputRef.current.focus();
            const val = (inputRef.current as HTMLInputElement | HTMLTextAreaElement).value ?? "";
            try {
                (inputRef.current as HTMLInputElement | HTMLTextAreaElement).setSelectionRange(val.length, val.length);
            } catch { }
        }
    }, [editingCell]);

    const startEdit = (rowIdx: number, colKey: keyof SubJob) => setEditingCell({ row: rowIdx, col: colKey });
    const stopEdit = () => setEditingCell(null);

    const updateCell = (rowIdx: number, colKey: keyof SubJob, value: string) => {
        setTableData(prev => {
            const next = [...prev];
            const old = next[rowIdx];
            if (!old) return prev;
            if (colKey === "volume") {
                const num = value === "" ? 0 : Number(value);
                next[rowIdx] = { ...old, volume: Number.isFinite(num) ? num : 0 };
            } else {
                next[rowIdx] = { ...old, [colKey]: value };
            }
            return next;
        });
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        if (e.key === "Enter") {
            if ((e.target as HTMLTextAreaElement).tagName !== "TEXTAREA") e.preventDefault();
            stopEdit();
        }
        if (e.key === "Escape") stopEdit();
    };

    const addRow = () => setTableData(prev => [...prev, { title: '', volume: 0, unitOfMeasurement: '', startDate: '', endDate: '' }]);
    const deleteRow = (idx: number) => {
        setTableData(prev => prev.filter((_, i) => i !== idx));
        if (editingCell?.row === idx) stopEdit();
    };

    useEffect(() => {
        const getData = async () => {
            const msgs: string[] = [];

            const { successCategories, messageCategories, resultCategories } = await GetWorkCategories();
            if (successCategories) {
                setWorks(resultCategories);
            } else {
                msgs.push(messageCategories || "Ошибка загрузки этапов работ");
            }

            const { successMeasurement, messageMeasurement, resultMeasurement } = await GetMeasurement();
            if (successMeasurement) {
                setMeasurement(resultMeasurement);
            } else {
                msgs.push(messageMeasurement || "Ошибка загрузки единиц измерения");
            }

            const { successkpgz, messagekpgz, resultkpgz } = await Getkpgz();
            if (successkpgz) {
                setkpgz(resultkpgz);
            } else {
                msgs.push(messagekpgz || "Ошибка загрузки КПГЗ");
            }

            setMessages(msgs);
        };
        getData();
    }, []);

    useEffect(() => {
        if (tableData.length > 0) {
            const firstStart = tableData[0].startDate || '';
            const lastEnd = tableData[tableData.length - 1].endDate || '';

            setStartDate(firstStart);
            setEndDate(lastEnd);
        } else {
            setStartDate('');
            setEndDate('');
        }
    }, [tableData]);




    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        try {
            const token = localStorage.getItem("access_token");
            const projectUuid = localStorage.getItem("projectUuid");

            if (!token || !projectUuid || !selectedWork) {
                setMessages(["Не хватает данных для сохранения"]);
                return;
            }

            const response1 = await fetch("https://test.foxstudios.ru:32460/api/project/create-project-schedule", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`,
                },
                body: JSON.stringify({
                    project_uuid: projectUuid,
                    work_uuid: selectedWork.uuid,
                }),
            });

            if (!response1.ok) {
                setMessages(["Ошибка при создании project_schedule"]);
                return;
            }

            console.log("✅ Первый запрос выполнен");
            const data1: { uuid: string } = await response1.json();
            const projectScheduleUuid = data1.uuid;

            const items = tableData.map(row => {
                const meas = measurement.find(m => m.title === row.unitOfMeasurement);
                return {
                    end_date: row.endDate,
                    is_complete: false,
                    measurement: meas?.id,
                    start_date: row.startDate,
                    target_volume: row.volume,
                    title: row.title,
                    uuid: null,
                };
            });

            console.log("📦 Items для второго запроса:", items);

            const response2 = await fetch("https://test.foxstudios.ru:32460/api/project/update-works-in-schedule", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`,
                },
                body: JSON.stringify({
                    items,
                    project_schedule_uuid: projectScheduleUuid,
                }),
            });

            if (!response2.ok) {
                setMessages(["Ошибка при обновлении work-schedule"]);
                return;
            }

            console.log("✅ Второй запрос выполнен");
            await response2.json();

            setMessages(["Этапы успешно сохранены"]);
            router.push('/list_objects/create_object/second_step/');
        } catch (err: unknown) {
            if (err instanceof Error) {
                setMessages([`Ошибка: ${err.message}`]);
            } else {
                setMessages(["Неизвестная ошибка"]);
            }
        }
    };




    const kpgzTitle = selectedWork ? kpgz.find(k => k.id === selectedWork.kpgz)?.code || '' : '';

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="min-h-[calc(100vh-50px)] w-[80%] bg-white px-[10%] flex flex-col items-center gap-4 ">
                <div className="w-full">
                    <p>Добавить этап работы</p>
                </div>
                <form onSubmit={handleSubmit} className="w-full flex flex-col gap-4">
                    <div className="flex flex-row justify-between gap-14">
                        <div className="w-full flex flex-col">
                            <label>Этап работы</label>
                            <select
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                                value={selectedWork?.uuid || ''}
                                onChange={(e) => {
                                    const selected = works.find(w => w.uuid === e.target.value);
                                    setSelectedWork(selected || null);
                                }}
                            >
                                <option value="" disabled>Выберите этап</option>
                                {works.map((item) => (
                                    <option value={item.uuid} key={item.uuid}>{item.title}</option>
                                ))}
                            </select>
                        </div>
                        <div className="w-full flex flex-col">
                            <label>КПГЗ</label>
                            <input
                                disabled
                                type="text"
                                value={kpgzTitle}
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                    </div>
                    <div className="flex flex-row justify-between gap-14">
                        <div className="w-full flex flex-col">
                            <label>Дата начала</label>
                            <input
                                disabled
                                type="text"
                                value={startDate}
                                onChange={(e) => setStartDate(e.target.value)}
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                        <div className="w-full flex flex-col">
                            <label>Дата окончание</label>
                            <input
                                disabled
                                type="text"
                                value={endDate}
                                onChange={(e) => setEndDate(e.target.value)}
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                    </div>
                    <p>Даты вводить строго в формате год-месяц-день (пример: 2025-10-31)</p>
                    <div className="w-full overflow-x-auto">
                        <table className="w-full table-fixed border-collapse">
                            <thead>
                                <tr className="bg-slate-100 text-left">
                                    <th className="px-4 py-3">Название работы</th>
                                    <th className="px-4 py-3 w-32">Объем</th>
                                    <th className="px-4 py-3">Единицы измерения</th>
                                    <th className="px-4 py-3">Дата начала*</th>
                                    <th className="px-4 py-3">Дата окончания*</th>
                                    <th className="px-4 py-3 w-[80px]"></th>
                                </tr>
                            </thead>
                            <tbody>
                                {tableData.map((item, itemIdx) => {
                                    const editing = editingCell?.row === itemIdx;
                                    return (
                                        <tr key={itemIdx} className="relative border-t border-slate-200 hover:bg-slate-50">
                                            <td onClick={() => startEdit(itemIdx, "title")}>
                                                {editing && editingCell?.col === "title" ? (
                                                    <textarea
                                                        ref={(el) => { inputRef.current = el; }}
                                                        value={item.title}
                                                        onChange={(e) => updateCell(itemIdx, "title", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-28 p-2 resize-y outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[48px]">{item.title || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "volume")}>
                                                {editing && editingCell?.col === "volume" ? (
                                                    <input
                                                        ref={(el) => { inputRef.current = el; }}
                                                        type="number"
                                                        value={item.volume}
                                                        onChange={(e) => updateCell(itemIdx, "volume", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">{item.volume}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "unitOfMeasurement")}>
                                                {editing && editingCell?.col === "unitOfMeasurement" ? (
                                                    <select
                                                        value={item.unitOfMeasurement}
                                                        onChange={(e) => updateCell(itemIdx, "unitOfMeasurement", e.target.value)}
                                                        onBlur={stopEdit}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    >
                                                        {measurement.map((meas) => (
                                                            <option value={meas.title} key={meas.title}>{meas.title}</option>
                                                        ))}
                                                    </select>
                                                ) : (
                                                    <div className="min-h-[36px]">{item.unitOfMeasurement || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "startDate")}>
                                                {editing && editingCell?.col === "startDate" ? (
                                                    <input
                                                        ref={(el) => { inputRef.current = el; }}
                                                        type="text"
                                                        value={item.startDate}
                                                        onChange={(e) => updateCell(itemIdx, "startDate", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">{item.startDate || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "endDate")}>
                                                {editing && editingCell?.col === "endDate" ? (
                                                    <input
                                                        ref={(el) => { inputRef.current = el; }}
                                                        type="text"
                                                        value={item.endDate}
                                                        onChange={(e) => updateCell(itemIdx, "endDate", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">{item.endDate || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td className="text-center">
                                                <button type="button" onClick={() => deleteRow(itemIdx)} className="h-9 px-3 rounded bg-white border hover:bg-red-50">🗑</button>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>

                    <div className="w-full flex items-center justify-between gap-4">
                        <button type="button" className="bg-red-700 text-white px-6 py-2 rounded-lg" onClick={addRow}>Добавить строку</button>
                        <button type="submit" className="bg-red-700 text-white px-6 py-2 rounded-lg">Сохранить</button>
                    </div>
                    {messages.length > 0 && (
                        <div className="w-full flex flex-col items-center gap-1 pt-2">
                            {messages.map((msg, idx) => (
                                <p
                                    key={idx}
                                    className={`text-sm ${msg.includes("успешно") ? "text-green-600" : "text-red-600"}`}
                                >
                                    {msg}
                                </p>
                            ))}
                        </div>
                    )}

                </form>
            </main>
        </div>
    );
}