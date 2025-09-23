'use client';

import { Header } from "@/app/components/header";

interface CheckList {
    id: number;
    questions: [{
        question: string;
        comment?: string;
    }]
}[]

const questionsList: CheckList[] = [{
    id: 1,
    questions: [
        {
            question: 'TestQuestion'
        },
    ]
}]

export default function Activation() {
    return (
        <div className="flex justify-center min-h-screen bg-[#D0D0D0] mt-[50px]">
            <Header />

            <main className="w-[80%] bg-white px-8 pt-2">
                <div className="w-full h-[40px] border-b-[1px] border-[#D0D0D0]">
                    <p>Активация объекта</p>
                </div>

                <div className="flex flex-row items-center gap-3 h-[40px]">
                    <label className="block text-sm mb-1">ИНН исполнителя</label>
                    <input
                        type="text"
                        className="w-[35%] h-[30px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                    />
                </div>

                <div>
                    {questionsList.map((questionsList, questionsListIdx) => (
                        <div key={questionsListIdx} className="flex flex-col gap-4">
                            <span>{questionsListIdx + 1}</span>
                            {questionsList.questions.map((question, questionIdx) => (
                                <div key={questionIdx} className="w-[75%] bg-[#8F6868] flex flex-col gap-3 p-3">
                                    <div className="flex">
                                        <p className="flex-1 w-[80%]">{questionsListIdx + 1} {questionIdx + 1} {question.question}</p>
                                        <select name="" id="">
                                            <option value="Не требуется">Не требуется</option>
                                            <option value="Да">Да</option>
                                            <option value="Нет">Нет</option>
                                        </select>
                                    </div>

                                    <textarea className="w-full bg-[#D0D0D0]"></textarea>
                                </div>
                            ))}
                        </div>
                    ))}
                </div>
            </main>
        </div>
    )
}