﻿/*
	单张纹理，使用纹理代替物体的漫反射颜色
*/
Shader "Unity Shaders Book/Chapter7/Single Texture"
{
	Properties
	{

		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)	// 控制整体色调
		_MainTex("Main Tex", 2D) = "white"{}				// 纹理
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8.0, 256.0)) = 20
	}
	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				// Transforms 2D UV by scale/bias property
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				// Use the texture to sample the diffuse color
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}
		
			ENDCG
		}
	}

	Fallback "Specular"
}
