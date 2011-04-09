CREATE TABLE blog_page (
    id            varchar(255) binary NOT NULL COMMENT '記事のURLの一部なす、.../article/***.html、の部分',
    title         varchar(255) binary NOT NULL,
    description   varchar(255) binary NOT NULL,
    content       text binary         NOT NULL,
    category_tag1 varchar(255)        NOT NULL,           
    category_tag2 varchar(255)        default NULL,           
    created_year  varchar(4)          NOT NULL,
    created_month varchar(4)          NOT NULL,
    created_at    datetime            NOT NULL,
    updated_at    timestamp           NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    
    PRIMARY KEY                    (id),
    UNIQUE  KEY title              (title),
    KEY         category_tag1      (category_tag1),
    KEY         category_tag2      (category_tag2),
    KEY         created_year_month (created_year,created_month),
    KEY         created_at         (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE blog_category (
    id            int(10) unsigned    NOT NULL auto_increment,
    tag           varchar(255)        NOT NULL COMMENT '大文字小文字は一緒でいいや',
    blog_page_ids mediumblob          NOT NULL COMMENT 'json形式 カテゴリ一覧を出すときにcategory_tag1とcategory_tag2を検索するのは煩わしい',
    created_date  date                NOT NULL,
    updated_at    timestamp           NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    
    PRIMARY KEY    (id),
    UNIQUE KEY tag (tag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE blog_by_month (
    id            int(10) unsigned  NOT NULL auto_increment,
    created_year  varchar(4)        NOT NULL,
    created_month varchar(4)        NOT NULL,
    article_count int(10) unsigned  NOT NULL default 0,
    updated_at    timestamp         NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    
    PRIMARY KEY              (id),
    UNIQUE  KEY uniq         (created_year,created_month),
    KEY         created_year (created_year),
    KEY         updated_at   (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE blog_by_year (
    id            int(10) unsigned  NOT NULL auto_increment,
    created_year  varchar(4)        NOT NULL,
    article_count int(10) unsigned  NOT NULL default 0,
    updated_at    timestamp         NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    
    PRIMARY KEY              (id),
    UNIQUE  KEY created_year (created_year),
    KEY         updated_at   (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
