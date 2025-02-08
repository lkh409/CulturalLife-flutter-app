# :memo: 문화 생활 기록 앱 README

![Image](https://github.com/user-attachments/assets/3aac51f6-cbaa-4e24-9a20-0f7ac5439cdb)

<br>
<br>

## :desktop_computer: 프로젝트 소개
* 축제, 영화, 뮤지컬 같은 즐긴 문화생활을 타임라인 형태로 기록하고, 관련 정보를 검색할 수 있는 문화 생활 기록 플러터 앱입니다.
* 검색 화면에서 영화, 축제, 뮤지컬을 모두 검색할 수 있습니다.

<br>
<br>

## :alarm_clock: 개발 기간
* 2023.05 ~ 2024.06

<br>
<br>

## :sparkles: 특징
- 내용 기록 화면에서 영화, 뮤지컬, 축제, 기타 장르를 선택하면 타임라인에 해당 장르에 맞는 이모티콘으로 표시됨
- 기록을 저장하면 타임라인 화면에 순서대로 나타나고, 기록을 누르면 본인이 작성한 기록이 팝업 화면으로 나타남

<br>
<br>

## :busts_in_silhouette: 역할
- 이강희: 타임라인 화면, 기록 상세 정보 띄우기
- 이수인: 검색창 화면, 검색 결과 화면 api 
- 이주영: 내용 기록창 화면, 작성 후 화면

<br>
<br>

## :gear: 개발 환경
- Flutter 2.8
- Dart
- 개발 도구 : Android Studio

<br>
<br>

## :page_facing_up: 기능 설명
클릭하여 각 항목별 기능을 자세히 살펴볼 수 있습니다.
<br>
<br>

<details>
<summary><b>메인화면(타임라인)</b></summary>

<br>
<br>- 메인화면으로 기록을 타임라인 형태로 나타낸다.
<br>- 오른쪽 하단의 플로팅 액션 버튼으로 새로작성/검색 선택이 가능하다.
<br>- 기록을 클릭하면 상세정보 팝업이 나온다.
<br>
|

![Image](https://github.com/user-attachments/assets/0adddc1b-2bd2-4e2c-ae2d-a2106fdc44ba)

![Image](https://github.com/user-attachments/assets/86cbf211-fe92-475e-885c-4cee364d803c)
|:--:|



</details>
<br>

<details>
<summary><b>검색창 화면</b></summary>

<br>
<br>- 영화, 축제, 뮤지컬로 분류
<br>- 검색 시 제목, (개봉/시작)날짜, 장소 or 평점을 보여준다.
<br>
  
|
- 검색하기 전 기본 화면
![Image](https://github.com/user-attachments/assets/103e6e79-cfd6-42c2-b80d-e51a8742730b)

- 검색 화면
![Image](https://github.com/user-attachments/assets/37f44511-c0cf-4e78-9c90-e77249e59605)


|:--:|
</details>
<br>


<details>
<summary><b>내용 기록 화면</b></summary>

<br>
<br>- 장르 선택이 가능하고, 평점을 매길 수 있다.
<br>- 해당 화면에서 선택한 장르는 메인화면의 표시 이모지로 이어진다.
<br>
  
|
![Image](https://github.com/user-attachments/assets/5efbd8fa-cdaa-416f-a0e9-1f545767e09f)
|:--:|
</details>
<br>



