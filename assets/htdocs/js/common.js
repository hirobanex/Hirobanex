/* はてなブックマーク数のカウント用スクリプト  */
var hatebuCount = function (_id ,_url) {
        if(!_id)        return;
        var pageURL = (_url) ? _url : document.URL;
        var url = 'http://b.hatena.ne.jp/entry/jsonlite/?url=' + pageURL + '&callback=this.ReceiveCount';
        //JSONの読み込み
        var target = document.createElement('script');
        target.charset = 'utf-8';
        target.src = url;
        document.body.appendChild(target);
        this.ReceiveCount = function(data) {
                //読み込み結果
                var count = (data)? data.count : 0; //ブックマーク数が0のときは数を0に
                document.getElementById(_id).innerHTML = (document.URL.match(/manage/i)) ? count : 'B!: ' +  count;
        };
}

/* ツイート数のカウント用スクリプト */
var tweetCount = function (_id ,_url) {
        if(!_id)        return;
        var pageURL = (_url) ? _url : document.URL;
        var url = 'http://urls.api.twitter.com/1/urls/count.json?url=' + pageURL + '&callback=this.ReceiveCount';
        //JSONの読み込み
        var target = document.createElement('script');
        target.charset = 'utf-8';
        target.src = url;
        document.body.appendChild(target);
        this.ReceiveCount = function(data) {
                //読み込み結果
                document.getElementById(_id).innerHTML = (document.URL.match(/manage/i)) ? data.count : 'Tweet: ' + data.count;
        };
}
