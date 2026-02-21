/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#46f0be',
          light: '#46f0be',
        },
        secondary: {
          DEFAULT: '#f0c81e',
          light: '#f0c81e',
        },
        accent: {
          DEFAULT: '#8278e6',
          light: '#8278e6',
        },
        base: {
          DEFAULT: '#f0fafa',
          light: '#f0fafa',
        },
        blue: {
          custom: '#0032c8',
        },
        green: {
          custom: '#00b400',
        },
        yellow: {
          custom: '#fadc00',
        },
        orange: {
          custom: '#fa6400',
        },
      },
    },
  },
  plugins: [],
}
