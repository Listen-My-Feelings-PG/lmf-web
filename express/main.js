//////////////////////////////////////////////////////////////////////
// Servidor NodeJS para las APIs del sistema de sábans de llamadas  //
// Autor: Francisco Manuel Jimenez                                  //   
//////////////////////////////////////////////////////////////////////
const express = require('express');
const fileUpload = require('express-fileupload');
const app = express();
const server = require('http').Server(app);

app.disable('x-powered-by');
//Librería para el uso de la carga de archivos
app.use(fileUpload());

app.use((req, res, next) => {
  //Cabeceras del CORS
  res.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
  if (req.method != 'OPTIONS')
    console.log(req.url, req.method, new Date().toLocaleString());
  else
    return res.sendStatus(200);
  next();
});

app.post('/upload', (req, res) => {
  let body = req.body;
  let files = req.files;
  console.log('body', body);
  console.log('files', files);
  return res.status(200).json('hold on...');
});

const port = process.env.PORT || 3000;

server.listen(port, (error) => {
  if (error)
    console.log('Error al iniciar servidor:', error, new Date().toLocaleString());
  console.log(`Server started on port`, port, new Date().toLocaleString());
});