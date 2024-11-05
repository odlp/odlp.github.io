---
title: Learning by making (small) things
date: 2020-05-25
---

Recently I’ve been working on a client’s ruby project which sends and receives
image data to an API. The project’s tests make use of the [VCR gem][VCR gem] to
record these HTTP interactions.

[VCR gem]: https://github.com/vcr/vcr

VCR performs admirably, as always, but there’s one fly in the ointment. The
recorded cassettes have a huge blob of binary data inline:

```yaml
---
http_interactions:
- request:
    method: post
    uri: https://example.com/process
    body:
      encoding: ASCII-8BIT
      string: !binary |-
        LS0tLS0tLS0tLS0tLVJ1YnlNdWx0aXBhcnRQb3N0LTJmNjMxMDE3MDgyOGE3YTM3MDMzYjA3
        NzAwYmYyYzczDQpDb250ZW50LURpc3Bvc2l0aW9uOiBmb3JtLWRhdGE7IG5hbWU9ImZvcm1h
        dCINCg0KcG5nDQotLS0tLS0tLS0tLS0tUnVieU11bHRpcGFydFBvc3QtMmY2MzEwMTcwODI4
        <snip>
```

This makes both `git diff` & `git add --patch` tedious. Also, the cassettes are
no longer entirely human readable.

Pained by these binary blobs I searched for a remedy and discovered that VCR
supports custom serializers. Neat!

To build a custom VCR serializer you need to implement the following methods:

- `#serialize`
- `#deserialize`
- `#file_extension`

After quick read over the existing serializers which ship with VCR and about 80
lines of code, I’d put together the ["better binary" serializer for VCR][serializer]. The
serializer persists binary data outside the VCR cassettes.

[serializer]: https://github.com/odlp/vcr_better_binary

The resulting cassette looks like this:

```yaml
http_interactions:
- request:
    method: post
    uri: https://example.com/process
    body:
      encoding: ASCII-8BIT
      bin_key: lymom-vudim-vunek-mobad-fepak-taset-zosyl-zuhaf-setag
  response:
    body:
      encoding: ASCII-8BIT
      bin_key: xohog-badok-paneg-memek-tahum-degab-kasip-pefik-colol
  # snip
```

And the binary data lives in a subdirectory:

```
spec/fixtures/vcr_cassettes
├── my-cassette.yml
└── bin_data
    ├── lymom-vudim-vunek-mobad-fepak-taset-zosyl-zuhaf-setag
    └── xohog-badok-paneg-memek-tahum-degab-kasip-pefik-colol
```

Will anyone use this gem? Time will tell.

What I’m excited about right now is rediscovering that buzz from **learning by
making something small**, in a free-form manner.

There’s a unique quality to working on a small self-contained challenge. You’re
free from the burdensome complexity that comes with a larger project. Unlike
following a tutorial you have to apply creative thought. You don’t know if the
outcome will be a success or failure.

Extending a library/tool you use regularly presents an excellent opportunity for
learning. Along the way, you end up reading at least part of the documentation
and code. You’ll gain insight into the inner workings. Two times isn’t a
pattern, but I experienced similar benefits after creating an [RSpec formatter][formatter].

[formatter]: https://github.com/odlp/rspec_overview

I thoroughly recommend giving this approach a try. Go forth and build!
