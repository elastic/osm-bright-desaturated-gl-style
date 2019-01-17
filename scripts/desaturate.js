const fs = require("fs");
const chroma = require("chroma-js");

const style = JSON.parse(fs.readFileSync("../osm-bright-gl-style/style.json", "utf8"));
debugger;
const newStyle = Object.assign({}, style);

newStyle.name = `${style.name}-desaturated`;

const layers = newStyle.layers;

const newLayers = layers.map(computeLayer);

function computeLayer(layer) {
  if (
    ["background", "fill", "line", "symbol"].indexOf(layer.type) !== -1 &&
    layer.paint
  ) {
    const paint = layer.paint;
    const types = Object.keys(paint).filter(key => {
      return (
        [
          "fill-color",
          "background-color",
          "line-color",
          "fill-outline-color",
          "text-color",
          "text-halo-color"
        ].indexOf(key) !== -1
      );
    });
    var sources = types.map(type => {
      const paintColor = paint[type];
      const colorDesaturated = desaturateColor(paintColor);
      return { [type]: colorDesaturated };
    });
    newPaint = Object.assign({}, paint, ...sources);
    layer.paint = newPaint;
  }
  return layer;
}

function desaturateColor(paintColor) {
  if (typeof paintColor == "string") {
    const colorDesaturated = chroma(paintColor)
      .desaturate(1.1)
      .brighten(0.33);
    return `rgba(${colorDesaturated.rgba().join(",")})`;
  } else if (
    typeof paintColor == "object" &&
    Array.isArray(paintColor["stops"])
  ) {
    const stops = paintColor["stops"].map(stop => {
      const newColor = desaturateColor(stop[1]);
      return [stop[0], newColor];
    });
    const newPaintColor = Object.assign({}, paintColor, { stops: stops });
    return newPaintColor;
  } else return paintColor;
}

newStyle.layers = newLayers;

fs.writeFileSync("./style.json", JSON.stringify(newStyle, null, 2));
