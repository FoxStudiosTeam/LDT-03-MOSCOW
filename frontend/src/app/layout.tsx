"use client";

import "./globals.css";

export default function RootLayout({
                                     children,
                                   }: Readonly<{
  children: React.ReactNode;
}>) {
  return (
      <html lang="ru">
      <head>
        <title>ЭСЖ</title>
        <meta
            name="description"
            content="Электронный строительный журнал"
        />
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/favicon.png" />
      </head>
      <body className="antialiased bg-black text-white">
      {children}
      </body>
      </html>
  );
}
