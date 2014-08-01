Shader "Hidden/Unlit/Transparent Packed 2"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 12 to 12
//   d3d9 - ALU: 12 to 12
//   d3d11 - ALU: 9 to 9, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 9 to 9, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Vector 5 [_ClipRange0]
Vector 6 [_ClipRange1]
Vector 7 [_ClipArgs1]
"!!ARBvp1.0
# 12 ALU
PARAM c[8] = { program.local[0],
		state.matrix.mvp,
		program.local[5..7] };
TEMP R0;
MUL R0.x, vertex.position.y, c[7].z;
MUL R0.y, vertex.position, c[7].w;
MAD R0.x, vertex.position, c[7].w, -R0;
MAD R0.y, vertex.position.x, c[7].z, R0;
MOV result.color, vertex.color;
MOV result.texcoord[0].xy, vertex.texcoord[0];
MAD result.texcoord[1].zw, R0.xyxy, c[6], c[6].xyxy;
MAD result.texcoord[1].xy, vertex.position, c[5].zwzw, c[5];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 12 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 4 [_ClipRange0]
Vector 5 [_ClipRange1]
Vector 6 [_ClipArgs1]
"vs_2_0
; 12 ALU
dcl_position0 v0
dcl_color0 v1
dcl_texcoord0 v2
mul r0.x, v0.y, c6.z
mul r0.y, v0, c6.w
mad r0.x, v0, c6.w, -r0
mad r0.y, v0.x, c6.z, r0
mov oD0, v1
mov oT0.xy, v2
mad oT1.zw, r0.xyxy, c5, c5.xyxy
mad oT1.xy, v0, c4.zwzw, c4
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "xbox360 " {
Keywords { }
Bind "vertex" Vertex
Bind "color" COLOR
Bind "texcoord" TexCoord0
Vector 6 [_ClipArgs1]
Vector 4 [_ClipRange0]
Vector 5 [_ClipRange1]
Matrix 0 [glstate_matrix_mvp] 4
// Shader Timing Estimate, in Cycles/64 vertex vector:
// ALU: 13.33 (10 instructions), vertex: 32, texture: 0,
//   sequencer: 10,  4 GPRs, 31 threads,
// Performance (if enough threads): ~32 cycles per vector
// * Vertex cycle estimates are assuming 3 vfetch_minis for every vfetch_full,
//     with <= 32 bytes per vfetch_full group.

"vs_360
backbbabaaaaabhaaaaaaammaaaaaaaaaaaaaaceaaaaaaaaaaaaabcaaaaaaaaa
aaaaaaaaaaaaaapiaaaaaabmaaaaaaolpppoadaaaaaaaaaeaaaaaabmaaaaaaaa
aaaaaaoeaaaaaagmaaacaaagaaabaaaaaaaaaahiaaaaaaiiaaaaaajiaaacaaae
aaabaaaaaaaaaahiaaaaaakeaaaaaaleaaacaaafaaabaaaaaaaaaahiaaaaaake
aaaaaamaaaacaaaaaaaeaaaaaaaaaaneaaaaaaaafpedgmgjhaebhcghhddbaakl
aaabaaadaaabaaaeaaabaaaaaaaaaaaaeehkaaaaeehkaaaaaaaaaaaadpiaaaaa
fpedgmgjhafcgbgoghgfdaaaaaaaaaaaaaaaaaaadpiaaaaadpiaaaaafpedgmgj
hafcgbgoghgfdbaaghgmhdhegbhegffpgngbhehcgjhifpgnhghaaaklaaadaaad
aaaeaaaeaaabaaaaaaaaaaaahghdfpddfpdaaadccodacodcdadddfddcodaaakl
aaaaaaaaaaaaaammaacbaaadaaaaaaaaaaaaaaaaaaaacigdaaaaaaabaaaaaaad
aaaaaaaeaaaaacjaaabaaaadaaaakaaeaacafaafaaaadafaaaabpbfbaaadpcka
aaaabaamaaaaaaaoaaaabaapaaaabaanhabfdaadaaaabcaamcaaaaaaaaaaeaag
aaaabcaameaaaaaaaaaagaakaaaaccaaaaaaaaaaafpibaaaaaaaagiiaaaaaaaa
afpicaaaaaaaagiiaaaaaaaaafpiaaaaaaaaacdpaaaaaaaamiapaaadaabliiaa
kbabadaamiapaaadaamgiiaaklabacadmiapaaadaalbdejeklababadmiapiado
aagmaadeklabaaadmiapaaadaakaahaakbabagaagebcaaaaaamgblgboaadadad
miadiaaaaabkbkaaocaaaaaamiapiaacaaaaaaaaocacacaamiadiaabaalabkla
ilabaeaemiamiaabaakmagkmilaaafafaaaaaaaaaaaaaaaaaaaaaaaa"
}

SubProgram "ps3 " {
Keywords { }
Matrix 256 [glstate_matrix_mvp]
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Vector 467 [_ClipRange0]
Vector 466 [_ClipRange1]
Vector 465 [_ClipArgs1]
"sce_vp_rsx // 11 instructions using 1 registers
[Configuration]
8
0000000b01090100
[Defaults]
3
467 4
00000000000000003f8000003f800000
466 4
00000000000000003f8000003f800000
465 4
447a0000447a0000000000003f800000
[Microcode]
176
401f9c6c0040030d8106c0836041ff84401f9c6c004008080106c08360419f9c
401f9c6c011d3008012e80c200619fa000001c6c009d102a813f80c360407ffc
401f9c6c01d0300d8106c0c360403f80401f9c6c01d0200d8106c0c360405f80
401f9c6c01d0100d8106c0c360409f80401f9c6c01d0000d8106c0c360411f80
00001c6c011d1000012a80d540209ffc00001c6c011d1000013fc0ffe0211ffc
401f9c6c011d200080aac0c020607fa1
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 80 // 80 used size, 5 vars
Vector 16 [_ClipRange0] 4
Vector 48 [_ClipRange1] 4
Vector 64 [_ClipArgs1] 4
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
BindCB "$Globals" 0
BindCB "UnityPerDraw" 1
// 12 instructions, 1 temp regs, 0 temp arrays:
// ALU 9 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedhipjpedpaipcofanlidandmohkfpjlccabaaaaaaeaadaaaaadaaaaaa
cmaaaaaajmaaaaaaciabaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
ieaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaahkaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaahkaaaaaaabaaaaaaaaaaaaaa
adaaaaaaadaaaaaaapaaaaaafdfgfpfagphdgjhegjgpgoaaedepemepfcaafeef
fiedepepfceeaaklfdeieefcbaacaaaaeaaaabaaieaaaaaafjaaaaaeegiocaaa
aaaaaaaaafaaaaaafjaaaaaeegiocaaaabaaaaaaaeaaaaaafpaaaaadpcbabaaa
aaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaaacaaaaaaghaaaaae
pccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaaddccabaaa
acaaaaaagfaaaaadpccabaaaadaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaa
aaaaaaaafgbfbaaaaaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaabaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaabaaaaaaadaaaaaa
pgbpbaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaa
abaaaaaadgaaaaafdccabaaaacaaaaaaegbabaaaacaaaaaadiaaaaaibcaabaaa
aaaaaaaabkbabaaaaaaaaaaackiacaaaaaaaaaaaaeaaaaaadcaaaaalecaabaaa
aaaaaaaaakbabaaaaaaaaaaadkiacaaaaaaaaaaaaeaaaaaaakaabaiaebaaaaaa
aaaaaaaaapaaaaaiicaabaaaaaaaaaaaegbabaaaaaaaaaaaogikcaaaaaaaaaaa
aeaaaaaadcaaaaalmccabaaaadaaaaaakgaobaaaaaaaaaaakgiocaaaaaaaaaaa
adaaaaaaagiecaaaaaaaaaaaadaaaaaadcaaaaaldccabaaaadaaaaaaegbabaaa
aaaaaaaaogikcaaaaaaaaaaaabaaaaaaegiacaaaaaaaaaaaabaaaaaadoaaaaab
"
}

SubProgram "gles " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec4 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
varying mediump vec4 xlv_COLOR;
uniform highp vec4 _ClipArgs1;
uniform highp vec4 _ClipRange1;
uniform highp vec4 _ClipRange0;
uniform highp mat4 glstate_matrix_mvp;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  tmpvar_1.xy = ((_glesVertex.xy * _ClipRange0.zw) + _ClipRange0.xy);
  highp vec2 ret_2;
  ret_2.x = ((_glesVertex.x * _ClipArgs1.w) - (_glesVertex.y * _ClipArgs1.z));
  ret_2.y = ((_glesVertex.x * _ClipArgs1.z) + (_glesVertex.y * _ClipArgs1.w));
  tmpvar_1.zw = ((ret_2 * _ClipRange1.zw) + _ClipRange1.xy);
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_COLOR = _glesColor;
  xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
  xlv_TEXCOORD1 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
varying mediump vec4 xlv_COLOR;
uniform highp vec4 _ClipArgs1;
uniform highp vec4 _ClipArgs0;
uniform sampler2D _MainTex;
void main ()
{
  mediump vec4 col_1;
  mediump vec4 mask_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (_MainTex, xlv_TEXCOORD0);
  mask_2 = tmpvar_3;
  mediump vec4 tmpvar_4;
  tmpvar_4 = clamp (ceil((xlv_COLOR - 0.5)), 0.0, 1.0);
  mediump vec4 tmpvar_5;
  tmpvar_5 = clamp ((((tmpvar_4 * 0.51) - xlv_COLOR) / -0.49), 0.0, 1.0);
  col_1.xyz = tmpvar_5.xyz;
  highp vec2 tmpvar_6;
  tmpvar_6 = ((vec2(1.0, 1.0) - abs(xlv_TEXCOORD1.xy)) * _ClipArgs0.xy);
  highp vec2 tmpvar_7;
  tmpvar_7 = ((vec2(1.0, 1.0) - abs(xlv_TEXCOORD1.zw)) * _ClipArgs1.xy);
  mediump vec4 tmpvar_8;
  tmpvar_8 = (mask_2 * tmpvar_4);
  mask_2 = tmpvar_8;
  highp float tmpvar_9;
  tmpvar_9 = (tmpvar_5.w * clamp (min (min (tmpvar_6.x, tmpvar_6.y), min (tmpvar_7.x, tmpvar_7.y)), 0.0, 1.0));
  col_1.w = tmpvar_9;
  col_1.w = (col_1.w * (((tmpvar_8.x + tmpvar_8.y) + tmpvar_8.z) + tmpvar_8.w));
  gl_FragData[0] = col_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec4 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
varying mediump vec4 xlv_COLOR;
uniform highp vec4 _ClipArgs1;
uniform highp vec4 _ClipRange1;
uniform highp vec4 _ClipRange0;
uniform highp mat4 glstate_matrix_mvp;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  tmpvar_1.xy = ((_glesVertex.xy * _ClipRange0.zw) + _ClipRange0.xy);
  highp vec2 ret_2;
  ret_2.x = ((_glesVertex.x * _ClipArgs1.w) - (_glesVertex.y * _ClipArgs1.z));
  ret_2.y = ((_glesVertex.x * _ClipArgs1.z) + (_glesVertex.y * _ClipArgs1.w));
  tmpvar_1.zw = ((ret_2 * _ClipRange1.zw) + _ClipRange1.xy);
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_COLOR = _glesColor;
  xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
  xlv_TEXCOORD1 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
varying mediump vec4 xlv_COLOR;
uniform highp vec4 _ClipArgs1;
uniform highp vec4 _ClipArgs0;
uniform sampler2D _MainTex;
void main ()
{
  mediump vec4 col_1;
  mediump vec4 mask_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (_MainTex, xlv_TEXCOORD0);
  mask_2 = tmpvar_3;
  mediump vec4 tmpvar_4;
  tmpvar_4 = clamp (ceil((xlv_COLOR - 0.5)), 0.0, 1.0);
  mediump vec4 tmpvar_5;
  tmpvar_5 = clamp ((((tmpvar_4 * 0.51) - xlv_COLOR) / -0.49), 0.0, 1.0);
  col_1.xyz = tmpvar_5.xyz;
  highp vec2 tmpvar_6;
  tmpvar_6 = ((vec2(1.0, 1.0) - abs(xlv_TEXCOORD1.xy)) * _ClipArgs0.xy);
  highp vec2 tmpvar_7;
  tmpvar_7 = ((vec2(1.0, 1.0) - abs(xlv_TEXCOORD1.zw)) * _ClipArgs1.xy);
  mediump vec4 tmpvar_8;
  tmpvar_8 = (mask_2 * tmpvar_4);
  mask_2 = tmpvar_8;
  highp float tmpvar_9;
  tmpvar_9 = (tmpvar_5.w * clamp (min (min (tmpvar_6.x, tmpvar_6.y), min (tmpvar_7.x, tmpvar_7.y)), 0.0, 1.0));
  col_1.w = tmpvar_9;
  col_1.w = (col_1.w * (((tmpvar_8.x + tmpvar_8.y) + tmpvar_8.z) + tmpvar_8.w));
  gl_FragData[0] = col_1;
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 4 [_ClipRange0]
Vector 5 [_ClipRange1]
Vector 6 [_ClipArgs1]
"agal_vs
[bc]
adaaaaaaaaaaabacaaaaaaffaaaaaaaaagaaaakkabaaaaaa mul r0.x, a0.y, c6.z
adaaaaaaaaaaacacaaaaaaoeaaaaaaaaagaaaappabaaaaaa mul r0.y, a0, c6.w
adaaaaaaaaaaaeacaaaaaaoeaaaaaaaaagaaaappabaaaaaa mul r0.z, a0, c6.w
acaaaaaaaaaaabacaaaaaakkacaaaaaaaaaaaaaaacaaaaaa sub r0.x, r0.z, r0.x
adaaaaaaabaaacacaaaaaaaaaaaaaaaaagaaaakkabaaaaaa mul r1.y, a0.x, c6.z
abaaaaaaaaaaacacabaaaaffacaaaaaaaaaaaaffacaaaaaa add r0.y, r1.y, r0.y
aaaaaaaaahaaapaeacaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov v7, a2
aaaaaaaaaaaaadaeadaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov v0.xy, a3
adaaaaaaabaaamacaaaaaaefacaaaaaaafaaaaoeabaaaaaa mul r1.zw, r0.yyxy, c5
abaaaaaaabaaamaeabaaaaopacaaaaaaafaaaaeeabaaaaaa add v1.zw, r1.wwzw, c5.xyxy
adaaaaaaabaaadacaaaaaaoeaaaaaaaaaeaaaaooabaaaaaa mul r1.xy, a0, c4.zwzw
abaaaaaaabaaadaeabaaaafeacaaaaaaaeaaaaoeabaaaaaa add v1.xy, r1.xyyy, c4
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 80 // 80 used size, 5 vars
Vector 16 [_ClipRange0] 4
Vector 48 [_ClipRange1] 4
Vector 64 [_ClipArgs1] 4
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
BindCB "$Globals" 0
BindCB "UnityPerDraw" 1
// 12 instructions, 1 temp regs, 0 temp arrays:
// ALU 9 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedekopiodhleifhpbfhdlmcdgacciegmkdabaaaaaakeaeaaaaaeaaaaaa
daaaaaaajaabaaaakiadaaaabiaeaaaaebgpgodjfiabaaaafiabaaaaaaacpopp
amabaaaaemaaaaaaadaaceaaaaaaeiaaaaaaeiaaaaaaceaaabaaeiaaaaaaabaa
abaaabaaaaaaaaaaaaaaadaaacaaacaaaaaaaaaaabaaaaaaaeaaaeaaaaaaaaaa
aaaaaaaaaaacpoppbpaaaaacafaaaaiaaaaaapjabpaaaaacafaaabiaabaaapja
bpaaaaacafaaaciaacaaapjaaeaaaaaeacaaadoaaaaaoejaabaaookaabaaoeka
afaaaaadaaaaahiaaaaanbjaadaapkkaaeaaaaaeabaaaeiaaaaaaajaadaappka
aaaaaaibacaaaaadabaaaiiaaaaakkiaaaaaffiaaeaaaaaeacaaamoaabaaoeia
acaaoekaacaaeekaafaaaaadaaaaapiaaaaaffjaafaaoekaaeaaaaaeaaaaapia
aeaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaagaaoekaaaaakkjaaaaaoeia
aeaaaaaeaaaaapiaahaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaacaaaaapoaabaaoeja
abaaaaacabaaadoaacaaoejappppaaaafdeieefcbaacaaaaeaaaabaaieaaaaaa
fjaaaaaeegiocaaaaaaaaaaaafaaaaaafjaaaaaeegiocaaaabaaaaaaaeaaaaaa
fpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaa
acaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaa
gfaaaaaddccabaaaacaaaaaagfaaaaadpccabaaaadaaaaaagiaaaaacabaaaaaa
diaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaabaaaaaaabaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaabaaaaaaaaaaaaaaagbabaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaabaaaaaaacaaaaaa
kgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaa
abaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaa
abaaaaaaegbobaaaabaaaaaadgaaaaafdccabaaaacaaaaaaegbabaaaacaaaaaa
diaaaaaibcaabaaaaaaaaaaabkbabaaaaaaaaaaackiacaaaaaaaaaaaaeaaaaaa
dcaaaaalecaabaaaaaaaaaaaakbabaaaaaaaaaaadkiacaaaaaaaaaaaaeaaaaaa
akaabaiaebaaaaaaaaaaaaaaapaaaaaiicaabaaaaaaaaaaaegbabaaaaaaaaaaa
ogikcaaaaaaaaaaaaeaaaaaadcaaaaalmccabaaaadaaaaaakgaobaaaaaaaaaaa
kgiocaaaaaaaaaaaadaaaaaaagiecaaaaaaaaaaaadaaaaaadcaaaaaldccabaaa
adaaaaaaegbabaaaaaaaaaaaogikcaaaaaaaaaaaabaaaaaaegiacaaaaaaaaaaa
abaaaaaadoaaaaabejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadadaaaa
faepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheoieaaaaaa
aeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaa
heaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaahkaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaacaaaaaaadamaaaahkaaaaaaabaaaaaaaaaaaaaaadaaaaaa
adaaaaaaapaaaaaafdfgfpfagphdgjhegjgpgoaaedepemepfcaafeeffiedepep
fceeaakl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 327
struct v2f {
    highp vec4 vertex;
    mediump vec4 color;
    highp vec2 texcoord;
    highp vec4 worldPos;
};
#line 320
struct appdata_t {
    highp vec4 vertex;
    mediump vec4 color;
    highp vec2 texcoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 315
uniform sampler2D _MainTex;
uniform highp vec4 _ClipRange0 = vec4( 0.0, 0.0, 1.0, 1.0);
uniform highp vec4 _ClipArgs0 = vec4( 1000.0, 1000.0, 0.0, 1.0);
uniform highp vec4 _ClipRange1 = vec4( 0.0, 0.0, 1.0, 1.0);
#line 319
uniform highp vec4 _ClipArgs1 = vec4( 1000.0, 1000.0, 0.0, 1.0);
#line 335
#line 352
#line 335
highp vec2 Rotate( in highp vec2 v, in highp vec2 rot ) {
    highp vec2 ret;
    ret.x = ((v.x * rot.y) - (v.y * rot.x));
    #line 339
    ret.y = ((v.x * rot.x) + (v.y * rot.y));
    return ret;
}
#line 342
v2f vert( in appdata_t v ) {
    #line 344
    v2f o;
    o.vertex = (glstate_matrix_mvp * v.vertex);
    o.color = v.color;
    o.texcoord = v.texcoord;
    #line 348
    o.worldPos.xy = ((v.vertex.xy * _ClipRange0.zw) + _ClipRange0.xy);
    o.worldPos.zw = ((Rotate( v.vertex.xy, _ClipArgs1.zw) * _ClipRange1.zw) + _ClipRange1.xy);
    return o;
}
out mediump vec4 xlv_COLOR;
out highp vec2 xlv_TEXCOORD0;
out highp vec4 xlv_TEXCOORD1;
void main() {
    v2f xl_retval;
    appdata_t xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.color = vec4(gl_Color);
    xlt_v.texcoord = vec2(gl_MultiTexCoord0);
    xl_retval = vert( xlt_v);
    gl_Position = vec4(xl_retval.vertex);
    xlv_COLOR = vec4(xl_retval.color);
    xlv_TEXCOORD0 = vec2(xl_retval.texcoord);
    xlv_TEXCOORD1 = vec4(xl_retval.worldPos);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 327
struct v2f {
    highp vec4 vertex;
    mediump vec4 color;
    highp vec2 texcoord;
    highp vec4 worldPos;
};
#line 320
struct appdata_t {
    highp vec4 vertex;
    mediump vec4 color;
    highp vec2 texcoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 315
uniform sampler2D _MainTex;
uniform highp vec4 _ClipRange0 = vec4( 0.0, 0.0, 1.0, 1.0);
uniform highp vec4 _ClipArgs0 = vec4( 1000.0, 1000.0, 0.0, 1.0);
uniform highp vec4 _ClipRange1 = vec4( 0.0, 0.0, 1.0, 1.0);
#line 319
uniform highp vec4 _ClipArgs1 = vec4( 1000.0, 1000.0, 0.0, 1.0);
#line 335
#line 352
#line 352
mediump vec4 frag( in v2f IN ) {
    mediump vec4 mask = texture( _MainTex, IN.texcoord);
    mediump vec4 mixed = xll_saturate_vf4(ceil((IN.color - 0.5)));
    #line 356
    mediump vec4 col = xll_saturate_vf4((((mixed * 0.51) - IN.color) / -0.49));
    highp vec2 factor = ((vec2( 1.0, 1.0) - abs(IN.worldPos.xy)) * _ClipArgs0.xy);
    highp float f = min( factor.x, factor.y);
    factor = ((vec2( 1.0, 1.0) - abs(IN.worldPos.zw)) * _ClipArgs1.xy);
    #line 360
    f = min( f, min( factor.x, factor.y));
    mask *= mixed;
    col.w *= clamp( f, 0.0, 1.0);
    col.w *= (((mask.x + mask.y) + mask.z) + mask.w);
    #line 364
    return col;
}
in mediump vec4 xlv_COLOR;
in highp vec2 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
void main() {
    mediump vec4 xl_retval;
    v2f xlt_IN;
    xlt_IN.vertex = vec4(0.0);
    xlt_IN.color = vec4(xlv_COLOR);
    xlt_IN.texcoord = vec2(xlv_TEXCOORD0);
    xlt_IN.worldPos = vec4(xlv_TEXCOORD1);
    xl_retval = frag( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 22 to 22, TEX: 1 to 1
//   d3d9 - ALU: 25 to 25, TEX: 1 to 1
//   d3d11 - ALU: 16 to 16, TEX: 1 to 1, FLOW: 1 to 1
//   d3d11_9x - ALU: 16 to 16, TEX: 1 to 1, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_ClipArgs0]
Vector 1 [_ClipArgs1]
SetTexture 0 [_MainTex] 2D
"!!ARBfp1.0
# 22 ALU, 1 TEX
PARAM c[3] = { program.local[0..1],
		{ -2.0408571, 0.5, 0.50976563, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEX R0, fragment.texcoord[0], texture[0], 2D;
ADD R1, fragment.color.primary, -c[2].y;
FLR R1, -R1;
MOV_SAT R1, -R1;
MUL R0, R1, R0;
ADD R0.x, R0, R0.y;
ADD R0.x, R0, R0.z;
ADD R2.x, R0, R0.w;
MAD R0, R1, c[2].z, -fragment.color.primary;
MUL_SAT R0, R0, c[2].x;
ABS R1.zw, fragment.texcoord[1];
ABS R1.xy, fragment.texcoord[1];
ADD R1.zw, -R1, c[2].w;
ADD R1.xy, -R1, c[2].w;
MUL R1.zw, R1, c[1].xyxy;
MUL R1.xy, R1, c[0];
MIN R1.z, R1, R1.w;
MIN R1.x, R1, R1.y;
MIN_SAT R1.x, R1, R1.z;
MUL R0.w, R0, R1.x;
MUL result.color.w, R0, R2.x;
MOV result.color.xyz, R0;
END
# 22 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_ClipArgs0]
Vector 1 [_ClipArgs1]
SetTexture 0 [_MainTex] 2D
"ps_2_0
; 25 ALU, 1 TEX
dcl_2d s0
def c2, -0.50000000, 0.50976563, -2.04085708, 1.00000000
dcl v0
dcl t0.xy
dcl t1
texld r0, t0, s0
add_pp r1, v0, c2.x
frc_pp r2, -r1
add_pp r1, -r1, -r2
abs r2.xy, t1
add r2.xy, -r2, c2.w
mul r2.xy, r2, c0
mov_pp_sat r1, -r1
mul_pp r0, r1, r0
mad_pp r1, r1, c2.y, -v0
mul_pp_sat r3, r1, c2.z
add_pp r0.x, r0, r0.y
add_pp r0.x, r0, r0.z
min r2.x, r2, r2.y
add_pp r0.x, r0, r0.w
mov r1.y, t1.w
mov r1.x, t1.z
abs r1.xy, r1
add r1.xy, -r1, c2.w
mul r1.xy, r1, c1
min r1.x, r1, r1.y
min_sat r1.x, r2, r1
mul_pp r1.x, r3.w, r1
mov_pp r2.xyz, r3
mul_pp r2.w, r1.x, r0.x
mov_pp oC0, r2
"
}

SubProgram "xbox360 " {
Keywords { }
Vector 0 [_ClipArgs0]
Vector 1 [_ClipArgs1]
SetTexture 0 [_MainTex] 2D
// Shader Timing Estimate, in Cycles/64 pixel vector:
// ALU: 16.00 (12 instructions), vertex: 0, texture: 4,
//   sequencer: 8, interpolator: 16;    6 GPRs, 30 threads,
// Performance (if enough threads): ~16 cycles per vector
// * Texture cycle estimates are assuming an 8bit/component texture with no
//     aniso or trilinear filtering.

"ps_360
backbbaaaaaaabdiaaaaabaaaaaaaaaaaaaaaaceaaaaaaoeaaaaabamaaaaaaaa
aaaaaaaaaaaaaalmaaaaaabmaaaaaakpppppadaaaaaaaaadaaaaaabmaaaaaaaa
aaaaaakiaaaaaafiaaacaaaaaaabaaaaaaaaaageaaaaaaheaaaaaaieaaacaaab
aaabaaaaaaaaaageaaaaaaheaaaaaaipaaadaaaaaaabaaaaaaaaaajiaaaaaaaa
fpedgmgjhaebhcghhddaaaklaaabaaadaaabaaaeaaabaaaaaaaaaaaaeehkaaaa
eehkaaaaaaaaaaaadpiaaaaafpedgmgjhaebhcghhddbaafpengbgjgofegfhiaa
aaaeaaamaaabaaabaaabaaaaaaaaaaaahahdfpddfpdaaadccodacodcdadddfdd
codaaaklaaaaaaaaaaaaaaabaaaaaaaaaaaaaaaaaaaaaabeabpmaabaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeaaaaaaamabaaaafaaaaaaaaaiaaaaaaaa
aaaacigdaaadaaahaaaaaaabaaaadafaaaaapbfbaaaapckaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaadpiaaaaalpaaaaaamaacjmlmdpacipfmaaabbaacaaaabcaa
meaaaaaaaaaagaadgaajbcaaccaaaaaabaaieaabbpbppgiiaaaaeaaamiapacaf
aaaalbaakaacppaamiapacaaaenngmaakaibppaabecdaaadaabkgnlbkbaaabaa
kiepadabaeaaaaebmkafaaaakjipadabagaaaaiamcababaabicbaaaaaakhkhml
opaeabadmiapacababaablaaklabppacbebcacacaalbgmblodaaadabklbcacac
aalblbmaodacadppmjahiaaaaamamgaakbabppaamiabacacaagmlbaaobacacaa
miaiiaaaaagmgmaaobacaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

SubProgram "ps3 " {
Keywords { }
Vector 0 [_ClipArgs0]
Vector 1 [_ClipArgs1]
SetTexture 0 [_MainTex] 2D
"sce_fp_rsx // 29 instructions using 3 registers
[Configuration]
24
ffffffff0000c0250003fffd000000000000840003000000
[Offsets]
2
_ClipArgs0 1 4
00000050
447a0000447a0000000000003f800000
_ClipArgs1 1 4
00000020
447a0000447a0000000000003f800000
[Microcode]
464
be020100c8011c9dc8000001c8003fe1060004005c043c9f0802000008020000
0000447a0000447a0000000000003f801e7e7d00c8001c9dc8000001c8000001
1800040080043c9e80020000800200000000447a0000447a0000000000003f80
0204080054001c9dfe000001c80000011004080000001c9caa000000c8000001
9e021700c8011c9dc8000001c8003fe13e800140c8011c9dc8000001c8003fe1
1e820340c9001c9d00020000c80000010000bf00000000000000000000000000
02048800c8081c9dfe080001c80000011e821140c9041c9fc8000001c8000001
1e828140c9041c9fc8000001c800000102840240c9041c9dc8040001c8000001
10840240ab041c9caa040000c80000011e800440c9041c9d00020000c9000003
80003f020000000000000000000000000282024055041c9d54040001c8000001
0882034001081c9cff080001c800000104820240ff041c9dfe040001c8000001
1082034055041c9d01040000c80000011e808240c9001c9d00020000c8000001
9d67c00200000000000000000000000010800200c9001c9d00080000c8000001
02820340ff041c9dab040000c800000110800240c9001c9d01040000c8000001
0e810140c9001c9dc8000001c8000001
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 80 // 80 used size, 5 vars
Vector 32 [_ClipArgs0] 4
Vector 64 [_ClipArgs1] 4
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
// 19 instructions, 3 temp regs, 0 temp arrays:
// ALU 16 float, 0 int, 0 uint
// TEX 1 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedklfkmeeaplibocmdnjmnhcmjgapbocgnabaaaaaakmadaaaaadaaaaaa
cmaaaaaaliaaaaaaomaaaaaaejfdeheoieaaaaaaaeaaaaaaaiaaaaaagiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaheaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaahkaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaahkaaaaaaabaaaaaaaaaaaaaaadaaaaaaadaaaaaaapapaaaafdfgfpfa
gphdgjhegjgpgoaaedepemepfcaafeeffiedepepfceeaaklepfdeheocmaaaaaa
abaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaa
fdfgfpfegbhcghgfheaaklklfdeieefcliacaaaaeaaaaaaakoaaaaaafjaaaaae
egiocaaaaaaaaaaaafaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaa
aaaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaa
gcbaaaadpcbabaaaadaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacadaaaaaa
aaaaaaakpcaabaaaaaaaaaaaegbobaaaabaaaaaaaceaaaaaaaaaaalpaaaaaalp
aaaaaalpaaaaaalpeccaaaafpcaabaaaaaaaaaaaegaobaaaaaaaaaaaefaaaaaj
pcaabaaaabaaaaaaegbabaaaacaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
diaaaaahdcaabaaaabaaaaaaegaabaaaaaaaaaaaegaabaaaabaaaaaaaaaaaaah
bcaabaaaabaaaaaabkaabaaaabaaaaaaakaabaaaabaaaaaadcaaaaajbcaabaaa
abaaaaaackaabaaaabaaaaaackaabaaaaaaaaaaaakaabaaaabaaaaaadcaaaaaj
bcaabaaaabaaaaaadkaabaaaabaaaaaadkaabaaaaaaaaaaaakaabaaaabaaaaaa
dcaaaaanpcaabaaaaaaaaaaaegaobaaaaaaaaaaaaceaaaaafmipacdpfmipacdp
fmipacdpfmipacdpegbobaiaebaaaaaaabaaaaaadicaaaakpcaabaaaaaaaaaaa
egaobaaaaaaaaaaaaceaaaaalmjmacmalmjmacmalmjmacmalmjmacmaaaaaaaal
pcaabaaaacaaaaaaegbobaiambaaaaaaadaaaaaaaceaaaaaaaaaiadpaaaaiadp
aaaaiadpaaaaiadpdiaaaaaigcaabaaaabaaaaaaagabbaaaacaaaaaaagibcaaa
aaaaaaaaacaaaaaadiaaaaaidcaabaaaacaaaaaaogakbaaaacaaaaaaegiacaaa
aaaaaaaaaeaaaaaaddaaaaahicaabaaaabaaaaaabkaabaaaacaaaaaaakaabaaa
acaaaaaaddaaaaahccaabaaaabaaaaaackaabaaaabaaaaaabkaabaaaabaaaaaa
ddcaaaahccaabaaaabaaaaaadkaabaaaabaaaaaabkaabaaaabaaaaaadiaaaaah
icaabaaaaaaaaaaadkaabaaaaaaaaaaabkaabaaaabaaaaaadgaaaaafhccabaaa
aaaaaaaaegacbaaaaaaaaaaadiaaaaahiccabaaaaaaaaaaaakaabaaaabaaaaaa
dkaabaaaaaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "flash " {
Keywords { }
Vector 0 [_ClipArgs0]
Vector 1 [_ClipArgs1]
SetTexture 0 [_MainTex] 2D
"agal_ps
c2 -0.5 0.509766 -2.040857 1.0
[bc]
ciaaaaaaaaaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r0, v0, s0 <2d wrap linear point>
abaaaaaaabaaapacahaaaaoeaeaaaaaaacaaaaaaabaaaaaa add r1, v7, c2.x
bfaaaaaaacaaapacabaaaaoeacaaaaaaaaaaaaaaaaaaaaaa neg r2, r1
aiaaaaaaacaaapacacaaaaoeacaaaaaaaaaaaaaaaaaaaaaa frc r2, r2
bfaaaaaaabaaapacabaaaaoeacaaaaaaaaaaaaaaaaaaaaaa neg r1, r1
acaaaaaaabaaapacabaaaaoeacaaaaaaacaaaaoeacaaaaaa sub r1, r1, r2
beaaaaaaacaaadacabaaaaoeaeaaaaaaaaaaaaaaaaaaaaaa abs r2.xy, v1
bfaaaaaaacaaadacacaaaafeacaaaaaaaaaaaaaaaaaaaaaa neg r2.xy, r2.xyyy
abaaaaaaacaaadacacaaaafeacaaaaaaacaaaappabaaaaaa add r2.xy, r2.xyyy, c2.w
adaaaaaaacaaadacacaaaafeacaaaaaaaaaaaaoeabaaaaaa mul r2.xy, r2.xyyy, c0
bfaaaaaaabaaapacabaaaaoeacaaaaaaaaaaaaaaaaaaaaaa neg r1, r1
bgaaaaaaabaaapacabaaaaoeacaaaaaaaaaaaaaaaaaaaaaa sat r1, r1
adaaaaaaaaaaapacabaaaaoeacaaaaaaaaaaaaoeacaaaaaa mul r0, r1, r0
adaaaaaaadaaapacabaaaaoeacaaaaaaacaaaaffabaaaaaa mul r3, r1, c2.y
acaaaaaaabaaapacadaaaaoeacaaaaaaahaaaaoeaeaaaaaa sub r1, r3, v7
adaaaaaaadaaapacabaaaaoeacaaaaaaacaaaakkabaaaaaa mul r3, r1, c2.z
bgaaaaaaadaaapacadaaaaoeacaaaaaaaaaaaaaaaaaaaaaa sat r3, r3
abaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaffacaaaaaa add r0.x, r0.x, r0.y
abaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaakkacaaaaaa add r0.x, r0.x, r0.z
agaaaaaaacaaabacacaaaaaaacaaaaaaacaaaaffacaaaaaa min r2.x, r2.x, r2.y
abaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaappacaaaaaa add r0.x, r0.x, r0.w
aaaaaaaaabaaacacabaaaappaeaaaaaaaaaaaaaaaaaaaaaa mov r1.y, v1.w
aaaaaaaaabaaabacabaaaakkaeaaaaaaaaaaaaaaaaaaaaaa mov r1.x, v1.z
beaaaaaaabaaadacabaaaafeacaaaaaaaaaaaaaaaaaaaaaa abs r1.xy, r1.xyyy
bfaaaaaaabaaadacabaaaafeacaaaaaaaaaaaaaaaaaaaaaa neg r1.xy, r1.xyyy
abaaaaaaabaaadacabaaaafeacaaaaaaacaaaappabaaaaaa add r1.xy, r1.xyyy, c2.w
adaaaaaaabaaadacabaaaafeacaaaaaaabaaaaoeabaaaaaa mul r1.xy, r1.xyyy, c1
agaaaaaaabaaabacabaaaaaaacaaaaaaabaaaaffacaaaaaa min r1.x, r1.x, r1.y
agaaaaaaabaaabacacaaaaaaacaaaaaaabaaaaaaacaaaaaa min r1.x, r2.x, r1.x
bgaaaaaaabaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa sat r1.x, r1.x
adaaaaaaabaaabacadaaaappacaaaaaaabaaaaaaacaaaaaa mul r1.x, r3.w, r1.x
aaaaaaaaacaaahacadaaaakeacaaaaaaaaaaaaaaaaaaaaaa mov r2.xyz, r3.xyzz
adaaaaaaacaaaiacabaaaaaaacaaaaaaaaaaaaaaacaaaaaa mul r2.w, r1.x, r0.x
aaaaaaaaaaaaapadacaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r2
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 80 // 80 used size, 5 vars
Vector 32 [_ClipArgs0] 4
Vector 64 [_ClipArgs1] 4
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
// 19 instructions, 3 temp regs, 0 temp arrays:
// ALU 16 float, 0 int, 0 uint
// TEX 1 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_1
eefiecedgidefjicpklgjjghhihkkhfaonfijdoiabaaaaaalaafaaaaaeaaaaaa
daaaaaaadaacaaaapaaeaaaahmafaaaaebgpgodjpiabaaaapiabaaaaaaacpppp
liabaaaaeaaaaaaaacaaciaaaaaaeaaaaaaaeaaaabaaceaaaaaaeaaaaaaaaaaa
aaaaacaaabaaaaaaaaaaaaaaaaaaaeaaabaaabaaaaaaaaaaaaacppppfbaaaaaf
acaaapkaaaaaaalpfmipacdplmjmacmaaaaaiadpbpaaaaacaaaaaaiaaaaacpla
bpaaaaacaaaaaaiaabaaadlabpaaaaacaaaaaaiaacaaaplabpaaaaacaaaaaaja
aaaiapkaecaaaaadaaaacpiaabaaoelaaaaioekaacaaaaadabaacpiaaaaaoela
acaaaakabdaaaaacacaacpiaabaaoeibacaaaaadabaadpiaabaaoeiaacaaoeia
afaaaaadaaaacdiaaaaaoeiaabaaoeiaacaaaaadaaaacbiaaaaaffiaaaaaaaia
aeaaaaaeaaaacbiaaaaakkiaabaakkiaaaaaaaiaaeaaaaaeaaaacbiaaaaappia
abaappiaaaaaaaiaaeaaaaaeabaacpiaabaaoeiaacaaffkaaaaaoelbafaaaaad
abaadpiaabaaoeiaacaakkkacdaaaaacaaaaagiaacaanclaacaaaaadaaaaagia
aaaaoeibacaappkaafaaaaadaaaaagiaaaaaoeiaaaaanckaakaaaaadacaaabia
aaaakkiaaaaaffiacdaaaaacadaaabiaacaakklacdaaaaacadaaaciaacaappla
acaaaaadaaaaagiaadaancibacaappkaafaaaaadaaaaagiaaaaaoeiaabaancka
akaaaaadacaaaciaaaaakkiaaaaaffiaakaaaaadaaaabciaacaaffiaacaaaaia
afaaaaadaaaacciaaaaaffiaabaappiaafaaaaadabaaciiaaaaaaaiaaaaaffia
abaaaaacaaaicpiaabaaoeiappppaaaafdeieefcliacaaaaeaaaaaaakoaaaaaa
fjaaaaaeegiocaaaaaaaaaaaafaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaae
aahabaaaaaaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaa
acaaaaaagcbaaaadpcbabaaaadaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaac
adaaaaaaaaaaaaakpcaabaaaaaaaaaaaegbobaaaabaaaaaaaceaaaaaaaaaaalp
aaaaaalpaaaaaalpaaaaaalpeccaaaafpcaabaaaaaaaaaaaegaobaaaaaaaaaaa
efaaaaajpcaabaaaabaaaaaaegbabaaaacaaaaaaeghobaaaaaaaaaaaaagabaaa
aaaaaaaadiaaaaahdcaabaaaabaaaaaaegaabaaaaaaaaaaaegaabaaaabaaaaaa
aaaaaaahbcaabaaaabaaaaaabkaabaaaabaaaaaaakaabaaaabaaaaaadcaaaaaj
bcaabaaaabaaaaaackaabaaaabaaaaaackaabaaaaaaaaaaaakaabaaaabaaaaaa
dcaaaaajbcaabaaaabaaaaaadkaabaaaabaaaaaadkaabaaaaaaaaaaaakaabaaa
abaaaaaadcaaaaanpcaabaaaaaaaaaaaegaobaaaaaaaaaaaaceaaaaafmipacdp
fmipacdpfmipacdpfmipacdpegbobaiaebaaaaaaabaaaaaadicaaaakpcaabaaa
aaaaaaaaegaobaaaaaaaaaaaaceaaaaalmjmacmalmjmacmalmjmacmalmjmacma
aaaaaaalpcaabaaaacaaaaaaegbobaiambaaaaaaadaaaaaaaceaaaaaaaaaiadp
aaaaiadpaaaaiadpaaaaiadpdiaaaaaigcaabaaaabaaaaaaagabbaaaacaaaaaa
agibcaaaaaaaaaaaacaaaaaadiaaaaaidcaabaaaacaaaaaaogakbaaaacaaaaaa
egiacaaaaaaaaaaaaeaaaaaaddaaaaahicaabaaaabaaaaaabkaabaaaacaaaaaa
akaabaaaacaaaaaaddaaaaahccaabaaaabaaaaaackaabaaaabaaaaaabkaabaaa
abaaaaaaddcaaaahccaabaaaabaaaaaadkaabaaaabaaaaaabkaabaaaabaaaaaa
diaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaabkaabaaaabaaaaaadgaaaaaf
hccabaaaaaaaaaaaegacbaaaaaaaaaaadiaaaaahiccabaaaaaaaaaaaakaabaaa
abaaaaaadkaabaaaaaaaaaaadoaaaaabejfdeheoieaaaaaaaeaaaaaaaiaaaaaa
giaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaheaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaapapaaaahkaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
acaaaaaaadadaaaahkaaaaaaabaaaaaaaaaaaaaaadaaaaaaadaaaaaaapapaaaa
fdfgfpfagphdgjhegjgpgoaaedepemepfcaafeeffiedepepfceeaaklepfdeheo
cmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaa
apaaaaaafdfgfpfegbhcghgfheaaklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3"
}

}

#LINE 94

		}
	}
	Fallback Off
}
