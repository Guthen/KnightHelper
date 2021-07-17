shader_type canvas_item;

uniform bool IS_ACTIVE = false;
uniform vec4 REPLACE_COLOR : hint_color = vec4( 1f, 1f, 1f, 1f );
uniform vec4 IGNORE_COLOR : hint_color = vec4( 0f, 0f, 0f, 1f );

void fragment() {
	COLOR = texture( TEXTURE, UV );
	
	if ( IS_ACTIVE && !( length( abs( COLOR.rgb - IGNORE_COLOR.rgb ) ) < .1 ) && COLOR.a == 1f ) {
		COLOR = REPLACE_COLOR;
	}
}