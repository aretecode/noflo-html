noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Flatten = require '../components/Flatten.coffee'
else
  Flatten = require 'noflo-html/components/Flatten.js'

describe 'Flatten component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = Flatten.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'flattening HTML structures inside item', ->
    it 'should be able to find a video and a paragraph', (done) ->
      sent =
        id: 'main'
        html: """
        <p>Hello world, <b>this</b> is some text</p>
        <video src="http://foo.bar"></video>
        <p class='pagination-centered'><img class='img-polaroid' src='http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png' /><img /></p>
        <p><button data-uuid="71bfc2e0-4a96-11e4-916c-0800200c9a66" data-role="cta" data-verb="purchase" data-price="96">Buy now</button></p>
        """

      expected =
        id: 'main'
        content: [
          type: 'text'
          html: '<p>Hello world, <b>this</b> is some text</p>'
        ,
          type: 'video'
          video: 'http://foo.bar/'
          html: '<video src="http://foo.bar/"></video>'
        ,
          type: 'image'
          src: 'http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png'
          html: '<img src="http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png">'
        ,
          type: 'cta'
          uuid: '71bfc2e0-4a96-11e4-916c-0800200c9a66'
          verb: 'purchase'
          price: '96'
          html: '<button data-uuid="71bfc2e0-4a96-11e4-916c-0800200c9a66" data-role="cta" data-verb="purchase" data-price="96">Buy now</button>'
        ]

      out.on 'data', (data) ->
        chai.expect(data).to.eql expected
        done()
      ins.send sent

  describe 'flattening HTML structures', ->
    it 'should be able to find a video and an image inside figures', (done) ->
      if console.timeEnd
        console.time 'flattening HTML structures'
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <p>Hello world, <b>this</b> is some text</p>
          <figure><iframe frameborder="0" src="http://www.youtube.com/embed/YzC7MfCtkzo"></iframe></figure>
          <figure><img alt=\"An illustration of NoFlo used to create a flow-based version of the Jekyll tool for converting text into content suitable for Web publishing.\" src=\"http://cnet3.cbsistatic.com/hub/i/r/2013/09/10/92df7aec-6ddf-11e3-913e-14feb5ca9861/resize/620x/929f354f66ca3b99ab045f6f15a6693a/noflo-jekyll.png\">An illustration of NoFlo used to create a flow-based version of the Jekyll tool for converting text into content suitable for Web publishing.</figure>
          <figure><div><img src=\"http://timenewsfeed.files.wordpress.com/2012/02/slanglol.jpg?w=480&amp;h=320&amp;crop=1\"></div>\n<figcaption><small>Tom Turley / <a href=\"http://www.gettyimages.com/\">Getty Images</a></small></figcaption></figure>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'text'
            html: '<p>Hello world, <b>this</b> is some text</p>'
          ,
            type: 'video'
            video: 'http://www.youtube.com/embed/YzC7MfCtkzo'
            html: '<iframe frameborder="0" src="http://www.youtube.com/embed/YzC7MfCtkzo"></iframe>'
          ,
            type: 'image'
            src: 'http://cnet3.cbsistatic.com/hub/i/r/2013/09/10/92df7aec-6ddf-11e3-913e-14feb5ca9861/resize/620x/929f354f66ca3b99ab045f6f15a6693a/noflo-jekyll.png'
            html: '<figure><img alt=\"An illustration of NoFlo used to create a flow-based version of the Jekyll tool for converting text into content suitable for Web publishing.\" src=\"http://cnet3.cbsistatic.com/hub/i/r/2013/09/10/92df7aec-6ddf-11e3-913e-14feb5ca9861/resize/620x/929f354f66ca3b99ab045f6f15a6693a/noflo-jekyll.png\">An illustration of NoFlo used to create a flow-based version of the Jekyll tool for converting text into content suitable for Web publishing.</figure>'
          ,
            type: 'image'
            src: 'http://timenewsfeed.files.wordpress.com/2012/02/slanglol.jpg?w=480&amp;h=320&amp;crop=1'
            caption: 'Tom Turley / <a href="http://www.gettyimages.com/">Getty Images</a>'
            html: "<figure><div><img src=\"http://timenewsfeed.files.wordpress.com/2012/02/slanglol.jpg?w=480&amp;h=320&amp;crop=1\"></div>\n<figcaption><small>Tom Turley / <a href=\"http://www.gettyimages.com/\">Getty Images</a></small></figcaption></figure>"
          ]
        ]

      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening HTML structures'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to find Embed.ly videos and audios', (done) ->
      if console.timeEnd
        console.time 'flattening HTML structures'
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <p>Hello world, <b>this</b> is some text</p>
          <iframe class=\"embedly-embed\" src=\"//cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2F8Dos61_6sss%3Ffeature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D8Dos61_6sss&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2F8Dos61_6sss%2Fhqdefault.jpg&key=internal&type=text%2Fhtml&schema=youtube\" width=\"500\" height=\"281\" scrolling=\"no\" frameborder=\"0\" allowfullscreen></iframe>
          <iframe class=\"embedly-embed\" src=\"//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fw.soundcloud.com%2Fplayer%2F%3Fvisual%3Dtrue%26url%3Dhttp%253A%252F%252Fapi.soundcloud.com%252Ftracks%252F153760638%26show_artwork%3Dtrue&url=http%3A%2F%2Fsoundcloud.com%2Fsupersquaremusic%2Fanywhere-everywhere-super-square-original&image=http%3A%2F%2Fi1.sndcdn.com%2Fartworks-000082002645-fhibur-t500x500.jpg%3Fe76cf77&key=internal&type=text%2Fhtml&schema=soundcloud\" width=\"500\" height=\"500\" scrolling=\"no\" frameborder=\"0\" allowfullscreen></iframe>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'text'
            html: '<p>Hello world, <b>this</b> is some text</p>'
          ,
            type: 'video'
            video: '//cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2F8Dos61_6sss%3Ffeature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D8Dos61_6sss&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2F8Dos61_6sss%2Fhqdefault.jpg&key=internal&type=text%2Fhtml&schema=youtube'
            html: '<iframe src=\"//cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2F8Dos61_6sss%3Ffeature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D8Dos61_6sss&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2F8Dos61_6sss%2Fhqdefault.jpg&key=internal&type=text%2Fhtml&schema=youtube\" width=\"500\" height=\"281\" scrolling=\"no\" frameborder=\"0\" allowfullscreen="allowfullscreen"></iframe>'
          ,
            type: 'audio'
            video: '//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fw.soundcloud.com%2Fplayer%2F%3Fvisual%3Dtrue%26url%3Dhttp%253A%252F%252Fapi.soundcloud.com%252Ftracks%252F153760638%26show_artwork%3Dtrue&url=http%3A%2F%2Fsoundcloud.com%2Fsupersquaremusic%2Fanywhere-everywhere-super-square-original&image=http%3A%2F%2Fi1.sndcdn.com%2Fartworks-000082002645-fhibur-t500x500.jpg%3Fe76cf77&key=internal&type=text%2Fhtml&schema=soundcloud'
            html: '<iframe src=\"//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fw.soundcloud.com%2Fplayer%2F%3Fvisual%3Dtrue%26url%3Dhttp%253A%252F%252Fapi.soundcloud.com%252Ftracks%252F153760638%26show_artwork%3Dtrue&url=http%3A%2F%2Fsoundcloud.com%2Fsupersquaremusic%2Fanywhere-everywhere-super-square-original&image=http%3A%2F%2Fi1.sndcdn.com%2Fartworks-000082002645-fhibur-t500x500.jpg%3Fe76cf77&key=internal&type=text%2Fhtml&schema=soundcloud\" width=\"500\" height=\"500\" scrolling=\"no\" frameborder=\"0\" allowfullscreen="allowfullscreen"></iframe>'
          ]
        ]

      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening HTML structures'
        chai.expect(data).to.eql expected
        done()
      ins.send sent
    it 'should be able to find images inside paragraphs', (done) ->
      if console.timeEnd
        console.time 'flattening HTML structures'
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <p>Hello world, <b>this</b> is some text</p>
          <p>Another exciting new product is <a href="http://noflojs.org/">NoFlo,</a> a flow-based Javascript programming tool. Developed as the result of a successful Kickstarter campaign (disclosure: I was a backer), it highlights both the dissatisfaction with the currently available tools, and the untapped potential for flow-based programming tools, that could be more easily understood by non-programmers. NoFlo builds upon Node.js to deliver functional apps to the browser. Native output to Android and iOS is in the works.<a href="http://noflojs.org/"><img src="http://netdna.webdesignerdepot.com/uploads/2014/07/0091.jpg" alt=""></a></p>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'text'
            html: '<p>Hello world, <b>this</b> is some text</p>'
          ,
            type: 'text'
            html: '<p>Another exciting new product is <a href="http://noflojs.org/">NoFlo,</a> a flow-based Javascript programming tool. Developed as the result of a successful Kickstarter campaign (disclosure: I was a backer), it highlights both the dissatisfaction with the currently available tools, and the untapped potential for flow-based programming tools, that could be more easily understood by non-programmers. NoFlo builds upon Node.js to deliver functional apps to the browser. Native output to Android and iOS is in the works.</p>'
          ,
            type: 'image'
            src: 'http://netdna.webdesignerdepot.com/uploads/2014/07/0091.jpg'
            html: '<a href="http://noflojs.org/"><img src="http://netdna.webdesignerdepot.com/uploads/2014/07/0091.jpg" alt=""></a>'
          ]
        ]

      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening HTML structures'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to normalize video and image URLs', (done) ->
      if console.timeEnd
        console.time 'URL normalization'
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'http://bergie.iki.fi/blog/ingress-table/'
          html: """
          <p>Hello world, <b>this</b> is some text</p>
          <video src="/files/foo.mp4"></video>
          <p class='pagination-centered'><img class='img-polaroid' src='../../files/image.gif' /><img /></p>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'http://bergie.iki.fi/blog/ingress-table/'
          content: [
            type: 'text'
            html: '<p>Hello world, <b>this</b> is some text</p>'
          ,
            type: 'video'
            video: 'http://bergie.iki.fi/files/foo.mp4'
            html: '<video src="http://bergie.iki.fi/files/foo.mp4"></video>'
          ,
            type: 'image'
            src: 'http://bergie.iki.fi/files/image.gif'
            html: '<img src="http://bergie.iki.fi/files/image.gif">'
          ]
        ]
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'URL normalization'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should retain groups', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <p>Hello world, <b>this</b> is some text</p>
          <video src="http://foo.bar"></video>
          """
        ]

      expected = ['foo', 'bar']
      found = []

      out.on 'begingroup', (group) ->
        found.push group
      out.on 'disconnect', ->
        chai.expect(found).to.eql expected
        done()
      ins.beginGroup grp for grp in expected
      ins.send sent
      ins.endGroup() for grp in expected
      ins.disconnect()

    it 'should be able to flatten a paragraph with only an image to an image', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <p><a href="http://foo.bar"><img src="http://foo.bar" alt="An image" title="My cool photo" data-foo="bar"></a></p>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'image'
            src: 'http://foo.bar/'
            title: 'My cool photo'
            caption: 'An image'
            html: '<a href="http://foo.bar/"><img src="http://foo.bar/" alt="An image" title="My cool photo" data-foo="bar"></a>'
          ]
        ]

      out.on 'data', (data) ->
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to flatten headlines and paragraphs', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <h1>Hello World</h1>
          <p class="intro">Some text</p>
          <h2 id="foo">Foo bar</h2>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'h1'
            html: '<h1>Hello World</h1>'
          ,
            type: 'text'
            html: '<p>Some text</p>'
          ,
            type: 'h2'
            html: '<h2>Foo bar</h2>'
          ]
        ]

      if console.timeEnd
        console.time 'flattening headlines and paragraphs'
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening headlines and paragraphs'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to flatten lists', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <ul>
            <li>Hello world<ul>
              <li>Foo</li>
            </ul></li>
            <li>Foo bar</li>
          </ul>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'list'
            html: '<ul><li>Hello world<ul><li>Foo</li></ul></li><li>Foo bar</li></ul>'
          ]
        ]

      if console.timeEnd
        console.time 'flattening lists'
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening lists'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to flatten things wrapped in divs', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <div>
          <ul>
            <li>Hello world<ul>
              <li>Foo</li>
            </ul></li>
            <li>Foo bar</li>
          </ul>
          </div>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'list'
            html: '<ul><li>Hello world<ul><li>Foo</li></ul></li><li>Foo bar</li></ul>'
          ]
        ]

      if console.timeEnd
        console.time 'flattening lists'
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening lists'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to flatten things wrapped multiple levels of structural tags', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <div>
          <section>
          <span>
          <ul>
            <li>Hello world<ul>
              <li>Foo</li>
            </ul></li>
            <li>Foo bar</li>
          </ul>
          </span>
          </section>
          </div>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'list'
            html: '<ul><li>Hello world<ul><li>Foo</li></ul></li><li>Foo bar</li></ul>'
          ]
        ]

      if console.timeEnd
        console.time 'flattening lists'
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening lists'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to discard useless content', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <p><span style=\"font-size: x-large;\"><br></br></span></p>
          <p>&nbsp;</p>
          <p><span style=\"font-size: large;\">Afterwards, we'll be running a dojo. No prior experience with FP is needed for this part; we'll all be coming from different levels. Our goals here are to equip you with a more of an understanding of functional programming and it's real-world applications and to learn from each other. More than all that: to have some fun with FP!</span></p>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'text'
            html: '<p>Afterwards, we\'ll be running a dojo. No prior experience with FP is needed for this part; we\'ll all be coming from different levels. Our goals here are to equip you with a more of an understanding of functional programming and it\'s real-world applications and to learn from each other. More than all that: to have some fun with FP!</p>'
          ]
        ]

      if console.timeEnd
        console.time 'flattening formatting'
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening formatting'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

    it 'should be able to detect iframe videos', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          html: """
          <iframe src="//player.vimeo.com/video/72238422?color=ffffff" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
          <iframe src="//foo.bar.com/foo"></iframe>
          """
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'video'
            video: '//player.vimeo.com/video/72238422?color=ffffff'
            html: '<iframe src="//player.vimeo.com/video/72238422?color=ffffff" width="500" height="281" frameborder="0" webkitallowfullscreen="webkitallowfullscreen" mozallowfullscreen="mozallowfullscreen" allowfullscreen="allowfullscreen"></iframe>'
          ,
            type: 'unknown'
            html: '<iframe src="//foo.bar.com/foo"></iframe>'
          ]
        ]

      if console.timeEnd
        console.time 'flattening iframes'
      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening iframes'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

  describe 'flattening a partially pre-flattened page', ->
    it 'should keep the already flattened parts as they were', (done) ->
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'text'
            html: '<p>Hello world, <b>this</b> is some text</p>'
          ,
            type: 'video'
            video: 'http://foo.bar/'
            html: '<video src="http://foo.bar/"></video>'
          ,
            type: 'image'
            src: 'http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png'
            html: '<img src="http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png">'
          ]
        ,
          id: 'new'
          html: """
          <p>Hello there</p>
          """
        ]
      expected =
        path: 'foo/bar.html'
        items: [
          id: 'main'
          content: [
            type: 'text'
            html: '<p>Hello world, <b>this</b> is some text</p>'
          ,
            type: 'video'
            video: 'http://foo.bar/'
            html: '<video src="http://foo.bar/"></video>'
          ,
            type: 'image'
            src: 'http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png'
            html: '<img src="http://blog.interfacevision.com/assets/img/posts/example_visual_language_minecraft_01.png">'
          ]
        ,
          id: 'new'
          content: [
            type: 'text'
            html: '<p>Hello there</p>'
          ]
        ]
      out.on 'data', (data) ->
        chai.expect(data).to.eql expected
        done()
      ins.send sent

  describe 'flattening Twitter-style HTML structures', ->
    it 'should be able to find a video and a paragraph', (done) ->
      if console.timeEnd
        console.time 'flattening HTML structures'
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'https://twitter.com/RonConway/status/472107533788672000'
          html: "Help <a href=\"/BUILDNational\" class=\"twitter-atreply pretty-link\" dir=\"ltr\"><s>@</s><b>BUILDnational</b></a> win $500,000 in the <a href=\"/hashtag/GoogleImpactChallenge?src=hash\" data-query-source=\"hashtag_click\" class=\"twitter-hashtag pretty-link js-nav\" dir=\"ltr\"><s>#</s><b>GoogleImpactChallenge</b></a>! VOTE here: <a href=\"http://t.co/7AzWeaex0D\" rel=\"nofollow\" dir=\"ltr\" data-expanded-url=\"http://bit.ly/1h0KqKN\" class=\"twitter-timeline-link\" target=\"_blank\" title=\"http://bit.ly/1h0KqKN\"><span class=\"tco-ellipsis\"></span><span class=\"invisible\">http://</span><span class=\"js-display-url\">bit.ly/1h0KqKN</span><span class=\"invisible\"></span><span class=\"tco-ellipsis\"><span class=\"invisible\">&nbsp;</span></span></a> <a href=\"/hashtag/BUILDgreaterimpact?src=hash\" data-query-source=\"hashtag_click\" class=\"twitter-hashtag pretty-link js-nav\" dir=\"ltr\"><s>#</s><b>BUILDgreaterimpact</b></a> <a href=\"/hashtag/togetherweBUILD?src=hash\" data-query-source=\"hashtag_click\" class=\"twitter-hashtag pretty-link js-nav\" dir=\"ltr\"><s>#</s><b>togetherweBUILD</b></a>"
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'https://twitter.com/RonConway/status/472107533788672000'
          content: [
            type: 'text'
            html: "<p>Help <a href=\"https://twitter.com/BUILDNational\">@<b>BUILDnational</b></a> win $500,000 in the <a href=\"https://twitter.com/hashtag/GoogleImpactChallenge?src=hash\">#<b>GoogleImpactChallenge</b></a>! VOTE here: <a href=\"http://t.co/7AzWeaex0D\" title=\"http://bit.ly/1h0KqKN\">http://bit.ly/1h0KqKN</a><a href=\"https://twitter.com/hashtag/BUILDgreaterimpact?src=hash\">#<b>BUILDgreaterimpact</b></a><a href=\"https://twitter.com/hashtag/togetherweBUILD?src=hash\">#<b>togetherweBUILD</b></a></p>"
          ]
        ]

      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening HTML structures'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

  describe 'flattening content with Article elements', ->
    it 'should produce an article block', (done) ->
      if console.timeEnd
        console.time 'flattening HTML structures'
      sent =
        path: 'foo/bar.html'
        items: [
          id: 'http://html5doctor.com/the-article-element/'
          html: "<article><h1>Apple</h1><p>The <b>apple</b> is the pomaceous fruit of the apple tree...</p></article><article><h1>Red Delicious</h1><img src=\"http://www.theproducemom.com/wp-content/uploads/2012/01/red_delicious_jpg.jpg\"><p>These bright red apples are the most common found in many supermarkets...</p></article>"
        ]

      expected =
        path: 'foo/bar.html'
        items: [
          id: 'http://html5doctor.com/the-article-element/'
          content: [
            type: 'article'
            html: "<article><h1>Apple</h1><p>The <b>apple</b> is the pomaceous fruit of the apple tree...</p></article>"
            title: 'Apple'
            caption: 'The <b>apple</b> is the pomaceous fruit of the apple tree...'
          ,
            type: 'article'
            html: "<article><h1>Red Delicious</h1><img src=\"http://www.theproducemom.com/wp-content/uploads/2012/01/red_delicious_jpg.jpg\"><p>These bright red apples are the most common found in many supermarkets...</p></article>"
            title: 'Red Delicious'
            caption: 'These bright red apples are the most common found in many supermarkets...'
            src: 'http://www.theproducemom.com/wp-content/uploads/2012/01/red_delicious_jpg.jpg'
          ]
        ]

      out.on 'data', (data) ->
        if console.timeEnd
          console.timeEnd 'flattening HTML structures'
        chai.expect(data).to.eql expected
        done()
      ins.send sent

  describe 'flattening a full XHTML file', ->
    return if noflo.isBrowser()
    it 'should produce flattened contents', (done) ->
      fs = require 'fs'
      path = require 'path'
      if console.timeEnd
        console.time 'flattening HTML structures'
      sourcePath = path.resolve __dirname, './fixtures/tika.xhtml'
      sent =
        path: 'foo/bar.html'
        html: fs.readFileSync sourcePath, 'utf-8'

      out.on 'data', (data) ->
        console.log data
        images = data.content.filter (block) -> block.type is 'image'
        chai.expect(images.length).to.equal 6
        srcs = images.map (image) -> image.src
        chai.expect(srcs).to.eql [
          'image1.jpg'
          'image2.jpg'
          'image3.jpg'
          'image4.jpg'
          'image5.jpg'
          'image6.jpg'
        ]
        texts = data.content.filter (block) -> block.type is 'text'
        chai.expect(texts.length).to.equal 4
        if console.timeEnd
          console.timeEnd 'flattening HTML structures'
        done()
      ins.send sent
