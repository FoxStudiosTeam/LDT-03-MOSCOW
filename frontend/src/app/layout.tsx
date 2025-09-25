"use client";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Script from "next/script";
import { useEffect, useState } from "react";
import { loadYMaps3 } from "./lib/ymaps";



const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});


export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <script src="https://api-maps.yandex.ru/v3/?apikey=d45d01ae-6365-4f2a-a300-f14c6204a7f2&lang=en_US"></script>
      </head>
      <body className="antialiased bg-black text-white">
        {children}
      </body>
    </html>
  );
}
