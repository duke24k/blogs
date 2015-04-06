#워드플레스에서 플러그인 내부에서 사용자 목록을 얻어보자.

PHP는 만져봤지만, 워드프레스는 플러그인을 만져본적이 없는데 만들어진 플러그인을 바탕으로 이래저래 수정작업을 하게 되었습니다.

그러면서 사용자 목록을 뽑는 작업을 하게 되었다.

수정하는 플러그인은 shortcode를 지원하고 있었다.

플러그인이 shortcode_tag이라는 shortcode를 지원하고 변수 field를 입력가능하다면 아래와 같이 워드프레스 본문에 입력할 수 있다. 

	[shortcode_tag	field=value]

그러면 해당 본문에서 해당 플러그인에서 shortcode_tag과 연결된 함수와 함께 입력된 변수도 같이 처리하면서 출력한다. 

이렇게 shortcode_tag과 연결된 함수 내부에서 적당한 부분에 분기를 시켜 
사용자 목록을 출력하게 되었다. 

그기에 앞서 사용자 목록에 입력하고 싶은 필드를 생성하고 데이타를 입력하기 
위해 사용자 가입시 입력항목을 넣을 만한 플러그인을 찾아 보았다. 

그래서 찾은  Reigister Plus Redux라는 plugin을 설치하고 
가입시 입력할 항목으로 rpr_meetings라는 필드를 만들었다. 
체크박스로 선택하고 입력가능한 항목으로 보라돌이,뚜비,나나를 입력했다.

사용자 정보를 updata_user_meta()라는 함수로 갱신을 해주었다.
가입할때 해당 레코드가 생성되어 있기때문에 
수정작업을 하는 plugin에서는 insert대신 update함수를 써주었다.

	$meta_field='rpr_meeting';
	$meta_value='보라돌이,뚜비,나나';
	update_user_meta( $current_user->ID, $meta_field, $meta_value );


$meta_value에는 분리자로 컴마(,)로 선택한 보라돌이,뚜비,나나가 입력되었다.

등록된 사용자 수를 검색했다. 

	$meta_key = 'rpr_meeting';
	$meta_value = '보라돌이';
	$sql = "SELECT COUNT(*) FROM $wpdb->usermeta WHERE meta_key='$meta_key' AND meta_value like '%$meta_value%' " ;
	$registered = $wpdb->get_var( $wpdb->prepare( $sql));
	$registering = $tickets > $registered ? true : false;
	

등록된 사용자를 검색했다.

	$users_query = new WP_User_Query( array('number'=>10,  'meta_key' => 'rpr_meeting', 'meta_value' => $meta_value, 'meta_compare' => 'like' ) );
	$users = $bbb_users_query->get_results();
	

등록된 사용자를 검색한뒤 wp_usermeta의 rpr_kname, rpr_org, rpr_dept 도 이용할 사용자 정보에 포함했다. 

	$th['rpr_kname'] = "이름";
	$th['rpr_org'] = "소속단체";
	$th['rpr_dept'] = "소속부서";
	
	foreach($bbb_users as $idx=>$bbb_user){
	        $data = get_user_meta($bbb_user->data->ID );
	        // return print_r($bbb_user, true);
	        $data = array_filter( array_map( function( $a ) { return $a[0]; }, $data ) );
	>
	        foreach($th as $tf=>$tv)
	                switch($tf){
	                case 'display_name':
	                        $tr[$idx][$tf] = $bbb_user->data->display_name;
	                break;
	                case 'user_url':
	                        $tr[$idx][$tf] = $bbb_user->data->user_url;
	                break;
	                default:
	                        $tr[$idx][$tf] = isset($data[$tf]) ? $data[$tf] : null;
	                }
	
	}
	

## 차근차근 필요한 기능을 검색하며 wp_usermeta에서 필요한 사용자 목록을 얻을 수 있었다. 

>쓰기를 잘할려면 먼저 읽기를 권장한다. 코드리딩은 또 다른 읽기로 코딩을 위해서는 선수항목이다. 워드프레스의 플러그인에서 사용자 목록을 뽑고 해당 작업을 할때 도움이 되길 빈다.

