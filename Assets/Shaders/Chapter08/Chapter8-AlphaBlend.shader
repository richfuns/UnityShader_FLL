﻿/*
	透明度混合
	逐片元着色
	漫反射+纹理
	
*/

Shader "Unity Shaders Book/Chapter 8/Alpha Blend"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1		// 控制整体的透明度
	}

	SubShader
	{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			// 关闭深度写入
			ZWrite Off
			// 开启并设置此Pass的混合模式
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos :TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				//o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.pos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0.rgb * saturate(dot(worldNormal, worldLight)) * albedo;

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);	// 设置透明通道（只有在开启混合模式后才有效）
			}

			ENDCG
		}
	}
	Fallback "Transparent/VertexLit"
}