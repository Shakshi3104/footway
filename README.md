#  SidewalkSurfaceTypeClassification

This application can classify sidewalk surface type from acceleration data obtained by iPhone or iPod touch.

When you launch the app, press the start button, put your iPhone in your bottoms' pocket, and walk, it will estimate the sidewalk surface type you walk on.

The model of sidewalk surface type classifier was trained via `tensorflow.keras`, and converted to Core ML model (`.mlmodel`) by using `coremltools`.

|![demo](materials/SSTC-demo.gif)|
|:-:|

## Requirements
- iOS 13.1+
- Xcode 11.5+
