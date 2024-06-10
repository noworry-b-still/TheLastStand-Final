#if defined(TRIPLANAR_PASS)
v2f vert (appdata v){
    v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

    o.pulseSpeed = GetPulse();
    o.cameraPos = GetCameraPos();
    o.objPos = GetObjPos();
    float objDist = distance(o.cameraPos, o.objPos);
    float maxr = _MaxRange;
    float minr = _MinRange;
    UNITY_BRANCH
    if (_TPUseGlobal == 0){
        maxr = _TPMaxRange;
        minr = _TPMinRange;
    }
    o.globalF = smoothstep(maxr, clamp(minr, 0, maxr-0.001), objDist);
    v.vertex.x *= 1.4;
    float4 a = mul(unity_CameraToWorld, v.vertex);
    float4 b = mul(unity_WorldToObject, a);
    o.raycast = UnityObjectToViewPos(b).xyz * float3(-1,-1,1);
    o.raycast *= (_ProjectionParams.z / o.raycast.z);
    o.pos = UnityObjectToClipPos(b);
    o.uv = ComputeGrabScreenPos(o.pos);
    return o;
}

float4 frag (v2f i) : SV_Target {
    MirrorCheck();
    float4 col = 0;
    UNITY_BRANCH
    if (_Triplanar > 0){
        float3 tpPos = lerp(i.cameraPos, i.objPos, _TPP2O);
        float radius = GetRadius(i, tpPos, _TPRadius, _TPFade);
        col = GetTriplanar(i, _TPTexture, _TPNoiseTex, _TPTexture_ST.xy, _TPNoiseTex_ST.xy, radius) * _TPColor;
        col.a *= _Opacity;
    }
    else discard;
    return col;
}
#endif

#if defined(ZOOM_PASS)
v2f vert (appdata v){
    v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

    o.pulseSpeed = GetPulse();
    o.objPos = GetObjPos();
    o.cameraPos = GetCameraPos();
    o.objDist = distance(o.cameraPos, o.objPos);
    float maxr = _MaxRange;
    float minr = _MinRange;
    UNITY_BRANCH
    if (_ZoomUseGlobal == 0){
        maxr = _ZoomMaxRange;
        minr = _ZoomMinRange;
    }
    o.globalF = smoothstep(maxr, clamp(minr, 0, maxr-0.001), o.objDist);
    o.letterbF = smoothstep(_MaxRange, clamp(_MinRange, 0, _MaxRange-0.001), o.objDist);
    v.vertex.x *= 1.4;
    float4 a = mul(unity_CameraToWorld, v.vertex);
    float4 b = mul(unity_WorldToObject, a);
    o.pos = UnityObjectToClipPos(b);
    o.uv = ComputeGrabScreenPos(o.pos);
    o.luv = o.uv.y;
    o.zoom = GetZoom(o.objPos, o.cameraPos, o.objDist, _ZoomMinRange, _ZoomStr);
    float zoomR = GetZoom(o.objPos, o.cameraPos, o.objDist, _ZoomMinRange, _ZoomStrR);
    float zoomG = GetZoom(o.objPos, o.cameraPos, o.objDist, _ZoomMinRange, _ZoomStrG);
    float zoomB = GetZoom(o.objPos, o.cameraPos, o.objDist, _ZoomMinRange, _ZoomStrB);
    o.zoomPos = GetZoomPos();
    o.uvR = 0;
    o.uvG = 0;
    o.uvB = 0;
    UNITY_BRANCH
    if (_Zoom == 1)
        o.uv = lerp(o.uv, o.zoomPos, o.zoom * o.pulseSpeed);
    else if (_Zoom == 2){
        o.uvR = lerp(o.uv, o.zoomPos, zoomR * o.pulseSpeed);
        o.uvG = lerp(o.uv, o.zoomPos, zoomG * o.pulseSpeed);
        o.uvB = lerp(o.uv, o.zoomPos, zoomB * o.pulseSpeed);
    }
    return o;
}

float4 frag (v2f i) : SV_Target {
    MirrorCheck();
    DoLetterbox(i);
    UNITY_BRANCH
    if (CanLetterbox(i)) return float4(0,0,0,1);
    float4 col = 0;
    UNITY_BRANCH
    if (_Zoom != 0){
		col = tex2Dproj(_ZoomGrab, i.uv);
        col.rgb = DoRGBZoom(i, col.rgb);
        col.a *= _Opacity;
    }
	else discard;
    return col;
}
#endif

#if defined(GHOSTING_PASS)
v2f vert (appdata v){
    v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

    o.pulseSpeed = GetPulse();
    o.objPos = GetObjPos();
    o.cameraPos = GetCameraPos();
    o.objDist = distance(o.cameraPos, o.objPos);
    o.globalF = step(o.objDist, _MaxRange);
    v.vertex.x *= 1.4;
    o.pos = GetVertexPos(v.vertex);
    o.uv = ComputeGrabScreenPos(o.pos);
    return o;
}

float4 frag (v2f i) : SV_Target {
    MirrorCheck();
	float4 col = 0;
	
	UNITY_BRANCH
	if (_FreezeFrame == 1 && _GhostingToggle == 1)
		discard;

	UNITY_BRANCH
	if (_FreezeFrame == 1){
		_GhostingToggle = 0;
		col = tex2Dproj(_GhostingGrab, i.uv);
	}

	UNITY_BRANCH
	if (_GhostingToggle == 1){
		col = tex2Dproj(_GhostingGrab, i.uv);
		float strength = _GhostingStr * i.globalF * i.pulseSpeed;
		col.a = strength;
	}

	return col;
}
#endif