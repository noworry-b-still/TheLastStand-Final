// Fog
int _Fog, _FogSafeZone, _FogUseGlobal;
float4 _FogColor;
float _FogMinRange, _FogMaxRange;
float _FogRadius, _FogFade;
float _FogSafeRadius, _FogSafeMaxRange;
float _FogP2O, _FogSafeOpacity;

// Screenspace Texture
int _SST, _SSTBlend, _SSTUseGlobal, _ManualScrub, _ScrubPos;
sampler2D _ScreenTex;
float4 _SSTColor;
float _SSTMinRange, _SSTMaxRange;
float _SSTWidth, _SSTHeight, _SSTScale;
float _SSTLR, _SSTUD;
float _SSTColumnsX, _SSTRowsY, _SSTAnimationSpeed, _SSTAnimatedDist;
float _SSTFrameSizeXP, _SSTFrameSizeYP, _SSTFrameSizeXN, _SSTFrameSizeYN;

// Triplanar
sampler2D _TPTexture, _TPNoiseTex;
int _Triplanar, _TPUseGlobal, _TPBlend;
float4 _TPTexture_ST, _TPNoiseTex_ST, _TPColor;
float3 _TPScroll, _TPNoiseScroll;
float _TPRadius, _TPFade, _TPMinRange, _TPMaxRange, _TPP2O, _TPThickness, _TPNoise, _TPScanFade;

// Letterbox
int _UseZoomFalloff, _Letterbox;
float _LetterboxStr;

// Zoom
sampler2D _ZoomGrab;
int _Zoom, _ZoomUseGlobal;
float _ZoomMinRange, _ZoomMaxRange;
float _ZoomStr, _ZoomStrR, _ZoomStrG, _ZoomStrB;

// Extras
sampler2D _GhostingGrab;
int _OLUseGlobal, _OutlineType, _GhostingToggle, _DeepFry, _Shift, _InvertX, _InvertY, _Sobel, _FreezeFrame, _DepthBufferToggle;
float _GhostingStr, _OLMinRange, _OLMaxRange;
float4 _OutlineCol, _BackgroundCol;
float3 _DBColor;
float _OutlineThiccS, _OutlineThiccN, _OutlineThresh, _SobelStr;
float _Flavor, _Heat, _Sizzle;
float _ShiftX, _ShiftY, _Rotate;
int _Pulse, _WaveForm, _PulseColor;
float _PulseSpeed, _NormalMapFilter, _NMFToggle, _NMFOpacity, _DBOpacity;