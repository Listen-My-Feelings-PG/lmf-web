/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {
      colors: {
        // Colores distintivos de la aplicación
        primary: {
          DEFAULT: '#0032c8',
          dark: '#001a64',
          light: '#3355d1',
        },
        success: '#00b400',
        warning: '#fadc00',
        danger: '#fa6400',
        info: '#46f0be',
        accent: '#f0c81e',
        purple: {
          DEFAULT: '#8278e6',
          dark: '#0f0628',
          darker: '#1a0e3a',
        },
        light: '#f0fafa',
      },
      backgroundColor: {
        'player': '#001a50',
        'dark': '#0f0628',
        'darker': '#1a0e3a',
      },
      fontFamily: {
        sans: ['Calibri', 'system-ui', '-apple-system', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
