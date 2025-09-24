'use client';

import { Header } from "@/app/components/header";
import { useState } from "react";

import React from "react";

export default function FirstStep() {

    const [address, setAddress] = useState<string>("");

    const onSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();

        const formattedAddress = address.trim().replace(/\s+/g, " ").replace(/ /g, "+");

        try {
            const request = await fetch(`https://geocode-maps.yandex.ru/v1/?apikey=YOUR_API_KEY&geocode=${formattedAddress}&format=json`, {
                method: "GET"
            });

            const data = await request.json()

            console.log(data)

        } catch (err) {
            console.error(err);
        }
    }

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8">
                <form onSubmit={onSubmit}>
                    <input
                        type="text"
                        className="w-[35%] h-[30px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                        onChange={(e) => setAddress(e.target.value)}
                    />

                    <input type="submit" />
                </form>
            </main>
        </div>
    )
}