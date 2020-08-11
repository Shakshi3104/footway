#  SidewalkSurfaceTypeClassification

This application can classify sidewalk surface type from acceleration data obtained by iPhone or iPod touch.

When you launch the app, press the start button, put your iPhone in your bottoms' pocket, and walk, it wil estimate the sidewalk surface type you walk on.

## Requirements
- iOS 13.1+
- Xcode 11.5+

## Model
### Model Metadata
- Type: Neural Network Classifier
- Size: 18MB
- input: MultiArray (Double 768)
- output: classLabel (6 type)
    - asphalt
    - gravel
    - lawn
    - grass
    - sand
    - mat

