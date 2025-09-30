'use client';

import { Header } from "@/app/components/header";
import React, { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { CreateProjectSchedule, Getkpgz, GetMeasurement, GetWorkCategories, UpdateWorksInSchedule } from "@/app/Api/Api";
import { Kpgz, Measurement, SubJob, WorkItem, Works } from "@/models";
import Image from "next/image";

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
    const [isSubmitting, setIsSubmitting] = useState(false);

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
            } else if (colKey === "startDate") {
                const newStart = new Date(value).getTime();
                const end = old.endDate ? new Date(old.endDate).getTime() : null;

                if (end && newStart > end) {
                    setMessages(["Дата начала не может быть позже даты окончания"]);
                    return prev;
                }

                next[rowIdx] = { ...old, startDate: value };
            } else if (colKey === "endDate") {
                const newEnd = new Date(value).getTime();
                const start = old.startDate ? new Date(old.startDate).getTime() : null;

                if (start && newEnd < start) {
                    setMessages(["Дата окончания не может быть раньше даты начала"]);
                    return prev;
                }

                next[rowIdx] = { ...old, endDate: value };
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

    const formatDate = (value: string): string => {
        if (!value) return "";
        const d = new Date(value);
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, "0");
        const day = String(d.getDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
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
            const validStarts = tableData
                .map(r => r.startDate)
                .filter(Boolean)
                .map(d => new Date(d).getTime());

            const validEnds = tableData
                .map(r => r.endDate)
                .filter(Boolean)
                .map(d => new Date(d).getTime());

            const minStart = validStarts.length ? new Date(Math.min(...validStarts)) : null;
            const maxEnd = validEnds.length ? new Date(Math.max(...validEnds)) : null;

            setStartDate(minStart ? formatDate(minStart.toISOString()) : "");
            setEndDate(maxEnd ? formatDate(maxEnd.toISOString()) : "");
        } else {
            setStartDate("");
            setEndDate("");
        }
    }, [tableData]);

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (isSubmitting) return;
        setIsSubmitting(true);

        try {
            const projectUuid = localStorage.getItem("projectUuid");

            if (!projectUuid || !selectedWork) {
                setMessages(["Не хватает данных для сохранения"]);
                setIsSubmitting(false);
                return;
            }

            const { success, message, result } = await CreateProjectSchedule(projectUuid, selectedWork.uuid);
            if (!success || !result) {
                setMessages([message || "Ошибка при создании project_schedule"]);
                setIsSubmitting(false);
                return;
            }
            const projectScheduleUuid = result.uuid;

            const items: WorkItem[] = tableData.map(row => {
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

            const { success: successUpd, message: messageUpd } = await UpdateWorksInSchedule(items, projectScheduleUuid);
            if (!successUpd) {
                setMessages([messageUpd || "Ошибка при обновлении work-schedule"]);
                setIsSubmitting(false);
                return;
            }

            setMessages(["Этапы успешно сохранены"]);
            router.push('/gant/edit');
        } catch (err: unknown) {
            console.error("Ошибка при сохранении:", err);
            setMessages(["Непредвиденная ошибка"]);
            setIsSubmitting(false);
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
                    <div className="flex flex-col sm:flex-row justify-between gap-2 sm:gap-14">
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
                    <div className="flex flex-col sm:flex-row justify-between gap-2 sm:gap-14">
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
                    <div className="w-full overflow-x-scroll">
                        <table className="w-full border-collapse table-auto">
                            <thead>
                                <tr className="bg-slate-100 text-left">
                                    <th className="px-4 py-3 min-w-[300px]">Название работы</th>
                                    <th className="px-4 py-3 w-32">Объем</th>
                                    <th className="px-4 py-3">Единицы измерения</th>
                                    <th className="px-4 py-3">Дата начала</th>
                                    <th className="px-4 py-3">Дата окончания</th>
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
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    >
                                                        <option value="" disabled>Выберите единицу</option>
                                                        {measurement.map((meas) => (
                                                            <option value={meas.title}
                                                                key={meas.title}>{meas.title}</option>
                                                        ))}
                                                    </select>

                                                ) : (
                                                    <div className="min-h-[36px]">{item.unitOfMeasurement ||
                                                        <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "startDate")}>
                                                {editing && editingCell?.col === "startDate" ? (
                                                    <input
                                                        ref={(el) => {
                                                            inputRef.current = el;
                                                        }}
                                                        type="date"
                                                        value={item.startDate}
                                                        onChange={(e) => updateCell(itemIdx, "startDate", formatDate(e.target.value))}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">
                                                        {item.startDate || <span className="text-slate-400">—</span>}
                                                    </div>
                                                )}
                                            </td>

                                            <td onClick={() => startEdit(itemIdx, "endDate")}>
                                                {editing && editingCell?.col === "endDate" ? (
                                                    <input
                                                        ref={(el) => {
                                                            inputRef.current = el;
                                                        }}
                                                        type="date"
                                                        value={item.endDate}
                                                        onChange={(e) => updateCell(itemIdx, "endDate", formatDate(e.target.value))}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">
                                                        {item.endDate || <span className="text-slate-400">—</span>}
                                                    </div>
                                                )}
                                            </td>

                                            <td className="text-center align-middle">
                                                <button
                                                    type="button"
                                                    onClick={() => deleteRow(itemIdx)}
                                                    className="flex h-12 w-12 items-center justify-center "
                                                >
                                                    <Image
                                                        alt="Удаление"
                                                        src="/Tables/delete.svg"
                                                        height={20}
                                                        width={20}
                                                        className="transition"
                                                    />
                                                </button>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>

                    <div className="w-full flex items-center flex-col sm:flex-row justify-between gap-4">
                        <button
                            type="button"
                            className="bg-red-700 text-white px-6 py-2 rounded-lg w-full sm:w-auto"
                            onClick={addRow}
                        >
                            Добавить строку
                        </button>
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className={`w-full sm:w-auto px-6 py-2 rounded-lg text-white ${isSubmitting ? "bg-gray-400 cursor-not-allowed" : "bg-red-700 hover:bg-red-800"
                                }`}
                        >
                            {isSubmitting ? "Сохранение..." : "Сохранить"}
                        </button>
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