float GetPulse(){
    float p = 1;
    UNITY_BRANCH
    if (_Pulse == 1){
        UNITY_BRANCH
        switch (_WaveForm){
            case 1: p = smoothstep(-1, 1, sin(_Time.y * _PulseSpeed)); break;
            case 2:	p = frac(_Time.y * (_PulseSpeed*0.5)); break;
            case 3: p = 1-frac(_Time.y * (_PulseSpeed*0.5)); break;
            case 4: p = round(frac(_Time.y * (_PulseSpeed*0.25))); break;
            case 5: p = abs((_Time.y * (_PulseSpeed*0.25)%2)-1); break;
            default: break;
        }  
    }
    return p;
}

void SobelKernel(v2f i, sampler2D tex, inout float n[8]){
    _OutlineThiccS = lerp(0.24, 1.26, _OutlineThiccS);
    float2 wh = _MSFXGrab_TexelSize.xy*_OutlineThiccS;
    n[0] = tex2Dproj(tex, i.uv + float4(-wh.x,-wh.y,0,0));
    n[1] = tex2Dproj(tex, i.uv + float4(0,-wh.y,0,0));
    n[2] = tex2Dproj(tex, i.uv + float4(wh.x,-wh.y,0,0));
    n[3] = tex2Dproj(tex, i.uv + float4(-wh.x,0,0,0));
    n[4] = tex2Dproj(tex, i.uv + float4(wh.x,0,0,0));
    n[5] = tex2Dproj(tex, i.uv + float4(-wh.x,wh.y,0,0));
    n[6] = tex2Dproj(tex, i.uv + float4(0,wh.y,0,0));
    n[7] = tex2Dproj(tex, i.uv + float4(wh.x,wh.y,0,0));
}

float GetSobel(v2f i, sampler2D tex){
    float n[8];
    SobelKernel(i, tex, n);
    float edge_h = (n[2] + n[4] + n[7]) - (n[0] + n[3] + n[5]);
    float edge_v = (n[0] + n[1] + n[2]) - (n[5] + n[6] + n[7]);
    return sqrt((edge_h * edge_h) + (edge_v * edge_v));
}

float3 DoNormalMap(v2f i, float3 col){
	UNITY_BRANCH
	if (_NMFToggle){
		float2 uv = i.uv.xy/i.uv.w;
		float2 l = uv + (float2(1,0)*_MSFXGrab_TexelSize);
		float2 r = uv + (float2(-1,0)*_MSFXGrab_TexelSize);
		float2 u = uv + (float2(0,1)*_MSFXGrab_TexelSize);
		float2 d = uv + (float2(0,-1)*_MSFXGrab_TexelSize);
		float M = GetGrayscale(col).r;
		float L = GrayscaleSample(l);
		float R = GrayscaleSample(r);	
		float U = GrayscaleSample(u);
		float D = GrayscaleSample(d);
		float X = ((R-M)+(M-L))*.5;
		float Y = ((D-M)+(M-U))*.5;
		float3 nmCol = 0.5 + (normalize(float3(X, Y, 1-_NormalMapFilter))) * 0.5;
		col = lerp(col, nmCol, i.globalF*_NMFOpacity*i.pulseSpeed);
	}
	return col;
}

float3 DoDepthBuffer(v2f i, float3 col){
	UNITY_BRANCH
	if (_DepthBufferToggle){
		float2 uv = i.uv.xy/i.uv.w;
		float3 depth = SampleDepthTex(uv) + GetNoise(uv, 0.001);
		depth *= _DBColor;
		col = lerp(col, depth, _DBOpacity*i.globalF*i.pulseSpeed);
	}
	return col;
}

// ---------------------------
// SST stuff
// ---------------------------
float2 ScaleUV(float2 uv0){
    uv0.x += _SSTLR;
    uv0.y -= _SSTUD;
    uv0.xy = (uv0.xy - 0.5) * _SSTScale + 0.5;
    uv0.x = (uv0.x - 0.5) * (_SSTWidth*-1.4) + 0.5;
    uv0.y = (uv0.y - 0.5) * _SSTHeight + 0.5;
    return uv0.xy;
}

float2 GetAnimatedUV(float2 uv0){
    float2 uv1 = ScaleUV(uv0);
    float2 size = float2(1/_SSTColumnsX, 1/_SSTRowsY);
    uint totalFrames = _SSTColumnsX * _SSTRowsY;
	uint index = 0;
	UNITY_BRANCH
	if (_ManualScrub == 1)
    	index = _ScrubPos;
	else
		index = _Time.y*_SSTAnimationSpeed;
    uint indexX = index % _SSTColumnsX;
    uint indexY = floor((index % totalFrames) / _SSTColumnsX);
    float2 offset = float2(size.x*indexX,-size.y*indexY);
    float2 uv2 = uv1*size;
    uv2.y = uv2.y + size.y*(_SSTRowsY - 1);
    uv1 = uv2 + offset;
    return uv1;
}

// ---------------------------
// Fog
// ---------------------------
float GetFogFalloff(float globalFalloff, float minRange, float objDist){
    float falloff = smoothstep(_FogMaxRange, minRange, objDist);
    falloff = min(globalFalloff, falloff);
    return falloff;
}

float3 DoFog(v2f i, float3 col){
    UNITY_BRANCH
    if (_Fog == 1){
        UNITY_BRANCH
        if (_FogSafeZone == 1){
            _FogSafeMaxRange = max(_FogRadius, _FogSafeMaxRange)+0.001;
            float enterSafety = smoothstep(_FogSafeMaxRange, _FogRadius, i.objDist);
            _FogRadius = lerp(_FogRadius, _FogSafeRadius, enterSafety);
            _FogP2O = lerp(_FogP2O, 1, enterSafety);
            _FogColor.a *= lerp(1, _FogSafeOpacity, enterSafety);
        }
        float noiseStr = (_FogColor.r+_FogColor.g+_FogColor.b)/3;
        noiseStr = lerp(0.0033,0.05,noiseStr);
        _FogColor.rgb += GetGrayscale(GetNoiseRGB(i.uv.xy, noiseStr));
        float3 fogSpace = lerp(i.cameraPos, i.objPos, _FogP2O);
        float radius = GetRadius(i, fogSpace, _FogRadius, _FogFade);
        _FogColor.rgb = lerp(col, _FogColor.rgb, _FogColor.a);
        float3 temp = lerp(col, _FogColor, i.fogF);
        col = lerp(temp, col, radius);
    }
    return col;
}

// ---------------------------
// Screenspace Texture Overlay
// ---------------------------
float3 GetSSTBlend(v2f i, float3 col){
    //if (FrameClip(i.uv.xy))
    //    return col;
    float2 uv0 = i.uvs.xy;
    float4 texCol = tex2D(_ScreenTex, uv0) * _SSTColor;
    col = lerp(col, texCol.rgb, texCol.a*i.sstF);
    return col;
}

float3 GetSSTAdd(v2f i, float3 col){
    float2 uv0 = i.uvs.xy;
    float4 texCol = tex2D(_ScreenTex, uv0) * _SSTColor;
    texCol.rgb = col + texCol.rgb;
    texCol *= _SSTColor;
    col = lerp(col, texCol.rgb, texCol.a*i.sstF);
    return col;
}

float3 GetSSTMult(v2f i, float3 col){
    float2 uv0 = i.uvs.xy;
    float4 texCol = tex2D(_ScreenTex, uv0) * _SSTColor;
    texCol.rgb = col * texCol.rgb;
    texCol *= _SSTColor;
    col = lerp(col, texCol, texCol.a*i.sstF);
    return col;
}

float3 GetSSTA(float2 uv0){
    uv0.xy = GetAnimatedUV(uv0);
    return tex2D(_ScreenTex, uv0) * _SSTColor;
}

float2 GetSSTAD(v2f i){
    float2 uv0 = i.uv.xy;
    UNITY_BRANCH
    if (_SST == 3){
        float2 uv2 = GetAnimatedUV(i.uvs);
        float2 animOffsetTex = UnpackNormal(tex2D(_ScreenTex, uv2)).rg;
        _SSTAnimatedDist *= i.sstF;
        float2 animOffset = animOffsetTex * _SSTAnimatedDist * _MSFXGrab_TexelSize.xy;
        uv0 += (animOffset * UNITY_Z_0_FAR_FROM_CLIPSPACE(i.uv.z));
    }
    return uv0;
}

float2 GetSSTUV(float2 uv0){
    UNITY_BRANCH
    switch (_SST){
        case 1: uv0 = ScaleUV(uv0); break;
        case 2: uv0 = GetAnimatedUV(uv0); break;
        default: break;
    }  
    return uv0;
}

float3 DoSST(v2f i, float3 col){
    UNITY_BRANCH
    if (_SST > 0 && _SST != 3){
        UNITY_BRANCH
        switch (_SSTBlend){
            case 0: col = GetSSTBlend(i, col); break;
            case 1: col = GetSSTAdd(i, col); break;
            case 2: col = GetSSTMult(i, col); break;
            default: break;
        }
    }
    return col;
}

// ---------------------------
// Extras
// ---------------------------
void DoDeepfry(){
    UNITY_BRANCH
    if (_DeepFry == 1){
        float sizzle = lerp(0, 2, _Sizzle);
        float heat = lerp(1, 2, _Heat);
        float heatC = lerp(0,0.2, _Heat);
        _FilterModel = 3;
        _AutoShift = 0;
        _Hue = _Flavor;
        _SaturationHSL = 1;
        _Luminance = heat*0.1;
        _HSLMin = 0;
        _HSLMax = 1;
        _HDR = 0.5*heat;
        _Contrast = 1+heatC;
        _Exposure = 0;
        _Invert = 0.234*heat;
        _InvertR = 0;
        _InvertG = 0;
        _InvertB = 0;
        _Noise = 0.024*sizzle;
        _BlurModel = 2;
        _RGBSplit = 1;
        _Flicker = 0;
        _DoF = 0;
        _BlurOpacity = 0.386*heat;
        _BlurStr = 0.513*sizzle;
        _PixelationStr = 0.058*sizzle;
        _RippleGridStr = 0;
    }
}

void DoPulse(float p){
    UNITY_BRANCH
    if (_Pulse == 1){
        _Amplitude *= p;
        _DistortionStr *= p;
        _BlurStr *= p;
        _PixelationStr *= p;
        _RippleGridStr *= p;
        _FogColor.a *= p;
        _ShiftX *= p;
        _ShiftY *= p;
    }
}

float2 DoUVShift(v2f i){
    i.uv.x -= _ShiftX * i.globalF;
    i.uv.y -= _ShiftY * i.globalF;
    return i.uv.xy;
}

float2 DoUVInvert(v2f i){
    float falloff = step(i.objDist, _MaxRange);
    i.uv.x = lerp(i.uv.x, 0.5-i.uv.x, _InvertX*falloff);
    i.uv.y = lerp(i.uv.y, 0.5-i.uv.y, _InvertY*falloff);
    return i.uv.xy;
}

float2 DoUVManip(v2f i){
    UNITY_BRANCH
    if (_Shift == 1){
        i.uv.xy = DoUVShift(i);
        i.uv.xy = DoUVInvert(i);
    }
    return i.uv.xy;
}

float3 SoftOutline(v2f i, float3 bg){
    float sobel = GetSobel(i, _CameraDepthTexture);
    sobel *= sobel * 1000;
    sobel = saturate(sobel);
    float interpolator = saturate(sobel*_OutlineThresh)*_OutlineCol.a;
    return lerp(bg, _OutlineCol.rgb, interpolator);
}

float3 SharpOutline(v2f i, float3 bg){
    float4 orValue = float4(wNorm, depth);
    float4 sampledValue = float4(0,0,0,0);
    const uint samples = 8;
    const float2 n[samples] = {
        float2(1,0),
        float2(1,1),
        float2(0,1),
        float2(-1,0),
        float2(-1,1),
        float2(1,-1),
        float2(0,-1),
        float2(-1,-1)
    };
    UNITY_UNROLL
    for(uint j = 1; j < samples; j++) {
        i.uv = float4(i.uv.xy+n[j]*_MSFXGrab_TexelSize.xy*_OutlineThiccN, i.uv.zw);
        GetDepth(i, wPos, wNorm, depth);
        sampledValue += float4(wNorm, depth);  
    }
    sampledValue /= samples;
    float interpolator = smoothstep(0, 1, length(orValue - sampledValue))*_OutlineCol.a;
    return lerp(_OutlineCol, bg, interpolator);
}

float3 DoOutline(v2f i, float3 col){
    UNITY_BRANCH
    if (_OutlineType > 0){
        float3 bg = lerp(col, _BackgroundCol.rgb, _BackgroundCol.a);
        float falloff = i.globalF * i.pulseSpeed;
        UNITY_BRANCH
        switch (_OutlineType){
            case 1: col = lerp(col, SoftOutline(i, bg), falloff); break;
            case 2: col = lerp(col, SharpOutline(i, bg), falloff); break;
            default: break;
        }
    }
    return col;
}

// ---------------------------
// Letterbox
// ---------------------------
bool CanLetterbox(v2f i){
    return (_Letterbox == 1 && ((i.luv >= (0.5-_LetterboxStr)) || (i.luv <= (_LetterboxStr))));
}

void DoLetterbox(v2f i){
    if (_UseZoomFalloff == 1)
        _LetterboxStr *= i.zoom*(2+_LetterboxStr);
    else
        _LetterboxStr *= i.letterbF;
}

// ---------------------------
// Zoom
// ---------------------------
float2 GetZoom(float3 objPos, float3 cameraPos, float objDist, float zoomMinRange, float zoomStr){
    float2 zoom = 0;
    UNITY_BRANCH
    if (_ZoomUseGlobal){
        _ZoomMaxRange = _MaxRange;
        _ZoomMinRange = _MinRange;
    }
    UNITY_BRANCH
    if (_Zoom > 0){
        float3 a, b, c;
        zoomStr = 1.0/lerp(1.0, 1.5, zoomStr);
        b = mul(unity_CameraToWorld, float4(0,0,1,1)).xyz-_WorldSpaceCameraPos;
        #if UNITY_SINGLE_PASS_STEREO
            a = normalize(unity_StereoWorldSpaceCameraPos[1] - unity_StereoWorldSpaceCameraPos[0]);
            b = normalize(b-dot(a,b)*a);
            c = normalize(objPos-cameraPos);
        #else
            b = normalize(b);
            c = normalize(objPos-_WorldSpaceCameraPos);
        #endif
        float zoomAmt = dot(b, c);
        float zoomed = 0;
        if (zoomAmt > zoomStr)
            zoomed = (zoomAmt - zoomStr) / zoomStr;
        float3 camDist = abs(objDist);
        float falloff = saturate((camDist - _ZoomMaxRange) / (zoomMinRange - _ZoomMaxRange));
        zoom.x = smoothlerp(0, zoomed, falloff);
        zoom.y = zoomed*falloff*2.0;
    }
    return zoom;
}

float3 DoRGBZoom(v2f i, float3 col){
    UNITY_BRANCH
    if (_Zoom == 2){
        col.r = tex2Dproj(_ZoomGrab, i.uvR).r;
        col.g = tex2Dproj(_ZoomGrab, i.uvG).g;
        col.b = tex2Dproj(_ZoomGrab, i.uvB).b;
    }
    return col;
}

float4 GetZoomPos(){
    float4 pos = 0;
    UNITY_BRANCH
    if (_Zoom > 0){
        float4 clipPos = UnityObjectToClipPos(float4(0,0,0,1));
        pos = ComputeScreenPos(clipPos);
    }
    return pos;
}