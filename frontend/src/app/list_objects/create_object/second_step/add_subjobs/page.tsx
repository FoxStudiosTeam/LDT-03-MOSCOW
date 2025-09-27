'use client';

import { Header } from "@/app/components/header";
import React, { useEffect, useRef, useState } from "react";
import { v4 as uuidv4 } from 'uuid';
import { useRouter } from "next/navigation";

interface SubJob {
    id: string;
    title: string;
    volume: number;
    unitOfMeasurement: string;
    startDate: string;
    endDate: string;
}

interface Job {
    id: string;
    title: string;
    startDate: string;
    endDate: string;
    subJobs: SubJob[];
}

export default function AddSubjobs() {
    const [tableData, setTableData] = useState<SubJob[]>([{
        id: uuidv4(),
        title: '',
        volume: 0,
        unitOfMeasurement: '',
        startDate: '',
        endDate: '',
    }]);

    const router = useRouter();
    const [jobTitle, setJobTitle] = useState('Этап-1');
    const [kpgz, setKpgz] = useState('');
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');

    const [editingCell, setEditingCell] = useState<{ row: number; col: keyof SubJob } | null>(null);
    const inputRef = useRef<HTMLInputElement | HTMLTextAreaElement | null>(null);

    useEffect(() => {
        if (inputRef.current) {
            inputRef.current.focus();
            const val = (inputRef.current as HTMLInputElement | HTMLTextAreaElement).value ?? "";
            try {
                (inputRef.current as HTMLInputElement | HTMLTextAreaElement).setSelectionRange(val.length, val.length);
            } catch {}
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

    const addRow = () => setTableData(prev => [...prev, { id: uuidv4(), title: '', volume: 0, unitOfMeasurement: '', startDate: '', endDate: '' }]);
    const deleteRow = (idx: number) => {
        setTableData(prev => prev.filter((_, i) => i !== idx));
        if (editingCell?.row === idx) stopEdit();
    };

    // ✅ onSubmit
    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();

        const newJob: Job = {
            id: uuidv4(),
            title: jobTitle,
            startDate,
            endDate,
            subJobs: tableData
        };

        console.log("Отправленные данные:", newJob);

        // тут можно отправить fetch/post на сервер
        // await fetch('/api/jobs', { method: 'POST', body: JSON.stringify(newJob) });

        router.push('/list_objects/create_object/second_step/');
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="min-h-[calc(100vh-50px)] w-[80%] bg-white px-[10%] flex flex-col items-center gap-4 ">
                <div className="w-full">
                    <p>Добавить этап работы</p>
                </div>

                <form onSubmit={handleSubmit} className="w-full flex flex-col gap-4">
                    {/* Input для job */}
                    <div className="flex flex-row justify-between gap-14">
                        <div className="w-full flex flex-col">
                            <label>Этап работы</label>
                            <select
                                value={jobTitle}
                                onChange={(e) => setJobTitle(e.target.value)}
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            >
                                <option value="Этап-1">Этап-1</option>
                                <option value="Этап-2">Этап-2</option>
                            </select>
                        </div>

                        <div className="w-full flex flex-col">
                            <label>КПГЗ</label>
                            <input
                                disabled
                                type="text"
                                value={kpgz}
                                onChange={(e) => setKpgz(e.target.value)}
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

                    {/* Таблица */}
                    <div className="w-full overflow-x-auto">
                        <table className="w-full table-fixed border-collapse">
                            <thead>
                                <tr className="bg-slate-100 text-left">
                                    <th className="px-4 py-3">Название работы</th>
                                    <th className="px-4 py-3 w-32">Объем</th>
                                    <th className="px-4 py-3">Единицы измерения</th>
                                    <th className="px-4 py-3">Дата начала</th>
                                    <th className="px-4 py-3">Дата окончание</th>
                                    <th className="px-4 py-3 w-[80px]"></th>
                                </tr>
                            </thead>
                            <tbody>
                                {tableData.map((item, itemIdx) => {
                                    const editing = editingCell?.row === itemIdx;
                                    return (
                                        <tr key={item.id} className="relative border-t border-slate-200 hover:bg-slate-50">
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
                                                        <option value="">—</option>
                                                        <option value="м²">м²</option>
                                                        <option value="м³">м³</option>
                                                        <option value="шт">шт</option>
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

                    {/* Кнопки */}
                    <div className="w-full flex items-center justify-between gap-4">
                        <button type="button" className="bg-red-700 text-white px-6 py-2 rounded-lg" onClick={addRow}>Добавить строку</button>
                        <button type="submit" className="bg-red-700 text-white px-6 py-2 rounded-lg">Сохранить</button>
                    </div>
                </form>
            </main>
        </div>
    );
}
