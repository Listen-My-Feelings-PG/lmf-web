/*import * as tf from '@tensorflow/tfjs-node';

export async function trainTensorFlowModel(data: any[]) {
  const model = tf.sequential();
  model.add(tf.layers.dense({ units: 10, inputShape: [data[0].features.length], activation: 'relu' }));
  model.add(tf.layers.dense({ units: 3, activation: 'softmax' }));

  model.compile({ optimizer: 'adam', loss: 'categoricalCrossentropy', metrics: ['accuracy'] });

  const xs = tf.tensor2d(data.map(d => Object.values(d.features)));
  const ys = tf.tensor2d(data.map(d => tf.oneHot([d.label - 1], 3).arraySync()[0]));

  await model.fit(xs, ys, { epochs: 50 });

  return model;
}

export async function makePrediction(features: any) {
  // Cargar modelo existente y realizar predicción
  const model = await tf.loadLayersModel('file://path-to-saved-model/model.json');
  const input = tf.tensor2d([Object.values(features)]);
  const prediction = model.predict(input) as tf.Tensor;
  return prediction.arraySync();
}*/
