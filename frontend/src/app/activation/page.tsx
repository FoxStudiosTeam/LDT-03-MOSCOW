"use client";

import { useState } from "react";
import { Header } from "@/app/components/header";

interface Question {
    id: number;
    question: string;
}

const questionsList: Question[] = [
    { id: 1, question: "Есть ли на объекте действующая лицензия?" },
    { id: 2, question: "Соответствует ли проектная документация нормативам?" },
    { id: 3, question: "Были ли выявлены дефекты при последней проверке?" },
    { id: 4, question: "Подписан ли договор с заказчиком?" },
    { id: 5, question: "Все ли подрядчики предоставили акты выполненных работ?" },
    {
        id: 6,
        question:
            "Соблюдены ли сроки поставки материалов по графику? Укажите причины, если нет.",
    },
    { id: 7, question: "Наличие согласования с инспекцией Ростехнадзора?" },
    {
        id: 8,
        question:
            "Имеется ли актуальный план по охране труда и технике безопасности?",
    },
    {
        id: 9,
        question:
            "Проводился ли инструктаж персонала в течение последних 30 дней?",
    },
    {
        id: 10,
        question:
            "Опишите состояние строительной площадки, наличие ограждений и предупреждающих знаковdsadsafdafjgnhhdfabhgjhfdaebfhsadbnfkhbnndshkjbfjhasdbfhjbsdhjfbhsadbf dsfbhasbfhdbaghbfkjdabb absjgbfahdjbgkhjlabdfhgbajhb jsdfjabghjkfdbghkabgjhab jbagjbfahgbhadbfghabhjb jagbhkabfdhgbahjbghkjab ajgbhfbaghjbafjkngakjh.",
    },
];

export default function Activation() {
    const [answers, setAnswers] = useState<
        { id: number; answer: string; comment: string }[]
    >([]);
    const [files, setFiles] = useState<File[]>([]);

    const handleAnswerChange = (id: number, field: "answer" | "comment", value: string) => {
        setAnswers((prev) => {
            const existing = prev.find((a) => a.id === id);
            if (existing) {
                return prev.map((a) =>
                    a.id === id ? { ...a, [field]: value } : a
                );
            }
            return [...prev, { id, answer: field === "answer" ? value : "", comment: field === "comment" ? value : "" }];
        });
    };

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files) {
            setFiles(Array.from(e.target.files));
        }
    };

    const handleSubmit = () => {
        const payload = {
            answers,
            files,
        };
        console.log("Отправка данных на сервер:", payload);
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />

            <main className="w-[80%] bg-white px-8">
                <div className="flex justify-center items-center w-full h-[40px] border-b-[1px] border-[#D0D0D0] text-center">
                    <p className="font-semibold">Активация объекта</p>
                </div>

                <div className="w-full flex flex-col items-center justify-center">
                    <div className="w-[70%] flex flex-row items-center gap-3 h-[40px] mb-6">
                        <label className="block text-sm mb-1">ИНН исполнителя</label>
                        <input
                            type="text"
                            className="w-[35%] h-[30px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                        />
                    </div>

                </div>

                <div className="mt-6">
                    <label className="block mb-2 font-medium">Прикрепить файлы:</label>
                    <input
                        type="file"
                        multiple
                        onChange={handleFileChange}
                        className="mb-4"
                    />
                </div>

                <button
                    onClick={handleSubmit}
                    className="bg-red-700 text-white px-6 py-2 mt-4 rounded-lg"
                >
                    Отправить
                </button>
            </main>
        </div>
    );
}
