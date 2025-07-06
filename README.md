# Simple Data Visualisation Web App

This is a web application for visualising transformer asset data, built with **Vue 3**, **TypeScript**, and **Vite**.

## Features

- **Interactive line chart** showing voltage readings for selected transformers
- **Search and filter** transformers by name, region, health, or ID
- **Checkbox selection** to choose which transformers to display on the chart
- **Hover details**: See detailed info for the nearest transformer at each timestamp
- **Persistent selection** and data using local storage
- **Responsive and user-friendly UI**

## Tech Stack

- [Vue 3](https://vuejs.org/)
- [TypeScript](https://www.typescriptlang.org/)
- [Vite](https://vitejs.dev/)

## Getting Started

1. Install dependencies:

   ```sh
   npm install
   ```

2. Run the development server:

   ```sh
   npm run dev
   ```

3. Build for production:
   ```sh
   npm run build
   ```

## Docker

You can build and run the app as a Docker container:

```sh
docker build -t data-visualiser .
docker run -p 8080:80 data-visualiser
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

---

This template uses Vue 3 `<script setup>` SFCs. Check out the [script setup docs](https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup) to learn more.
