﻿Shader "UI/Indexed16"
{
	Properties
	{
		_MainTex ("MainTexture", 2D) = "white" {}
		_TableTex ("TableTexture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			sampler2D _TableTex;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// 左画素のIndexと、右画素のIndexを分離
				half indexEncoded = tex2D(_MainTex, i.uv).a * (255.01 / 16); // 整数部が左画素、少数部が右画素。.01は誤差対策。
				half indexRight = frac(indexEncoded);
				half indexLeft = (indexEncoded - indexRight) / 16;
				// 左画素なのか右画素なのかを判定
				half texcoordX = i.uv.x * _MainTex_TexelSize.z; // ピクセル単位座標に変換(幅半分のテクスチャでの)
				// 2倍して「元の幅」にし、これを0.5倍してfracが0.5なら右で、0なら左。2倍して0.5倍なので、そのまま。
				half index = (frac(texcoordX) < 0.49) ? indexLeft : indexRight; // 非2羃テクスチャで誤差が出た時のために少し甘めに見ておく
				fixed4 col = tex2D(_TableTex, index.xx);
				return col;
			}
			ENDCG
		}
	}
}
