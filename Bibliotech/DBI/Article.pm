package Bibliotech::Article;
use strict;
use base 'Bibliotech::DBI';

__PACKAGE__->table('article');
__PACKAGE__->columns(Primary => qw/article_id/);
__PACKAGE__->columns(Essential => qw/hash/);
__PACKAGE__->columns(Others => qw/created updated/);
__PACKAGE__->columns(TEMP => qw/x_adding x_for_user_article user_article_count_packed tags_packed/);
__PACKAGE__->datetime_column('created', 'before_create');
__PACKAGE__->datetime_column('updated', 'before_update');
__PACKAGE__->has_many(user_articles => 'Bibliotech::User_Article');

sub my_alias {
  'a';
}

sub unique {
  'hash';
}

sub packed_select {
  my $self = shift;
  my $alias = $self->my_alias;
  return (map("$alias.$_", $self->_essential),
	  'COUNT(DISTINCT ua2.user_article_id) as user_article_count_packed',
	  Bibliotech::DBI::packing_groupconcat('Bibliotech::Tag', 't2', 'tags_packed', 'uat2.created'),
	  );
}

sub count_active {
  # use user_article table; it's faster
  Bibliotech::User_Article->sql_single('COUNT(DISTINCT article)')->select_val;
}

sub delete {
  my $self = shift;
  foreach my $bookmark ($self->bookmarks) {
    $bookmark->delete;
  }
  $self->SUPER::delete(@_);
}

# adding means that the article is being added at this very moment so a full display is not appropriate
# behaviour of 'adding' property:
# 0 = regular article
# 1 = suppress most supplemental links (edit, copy, remove) and privacy note      (this level used on add form)
# 2 = suppress 'info' supplemental link
# 3 = show quotes around tags with spaces in Bibliotech::User_Article->postedby() (this level used on upload form)
# 4 = will not be added, suppress posted by                                       (this level used on upload form)
sub adding {
  my $self = shift;
  $self->remove_from_object_index if @_;
  return $self->x_adding(@_);
}

sub for_user_article {
  my $self = shift;
  $self->remove_from_object_index if @_;
  return $self->x_for_user_article(@_);
}

sub html_content {
  shift->label;
}

__PACKAGE__->set_sql(by_pubmed => <<'');
SELECT   __ESSENTIAL(a)__
FROM     __TABLE(Bibliotech::Citation=c)__
         LEFT JOIN __TABLE(Bibliotech::Bookmark=b)__ ON (__JOIN(c b)__)
         LEFT JOIN __TABLE(Bibliotech::Article=a)__ ON (__JOIN(b a)__)
WHERE    c.pubmed = ?
AND      b.bookmark_id IS NOT NULL
AND      a.article_id IS NOT NULL
AND      c.citation_id != ?

__PACKAGE__->set_sql(by_doi => <<'');
SELECT   __ESSENTIAL(a)__
FROM     __TABLE(Bibliotech::Citation=c)__
         LEFT JOIN __TABLE(Bibliotech::Bookmark=b)__ ON (__JOIN(c b)__)
         LEFT JOIN __TABLE(Bibliotech::Article=a)__ ON (__JOIN(b a)__)
WHERE    c.doi = ?
AND      b.bookmark_id IS NOT NULL
AND      a.article_id IS NOT NULL
AND      c.citation_id != ?

__PACKAGE__->set_sql(by_asin => <<'');
SELECT   __ESSENTIAL(a)__
FROM     __TABLE(Bibliotech::Citation=c)__
         LEFT JOIN __TABLE(Bibliotech::Bookmark=b)__ ON (__JOIN(c b)__)
         LEFT JOIN __TABLE(Bibliotech::Article=a)__ ON (__JOIN(b a)__)
WHERE    c.asin = ?
AND      b.bookmark_id IS NOT NULL
AND      a.article_id IS NOT NULL
AND      c.citation_id != ?

sub find_for_bookmark_and_citation {
  my ($self, $bookmark, $citation) = @_;
  my $article = $bookmark->article;
  return $article if defined $article and $article->id != 0;
  ($article) = $self->search(hash => $bookmark->hash);
  return $article if defined $article;
  if (defined $citation) {
    if (my $pubmed = $citation->pubmed) {
      my ($article) = $self->search_by_pubmed($pubmed, $citation->id || 0);
      return $article if defined $article;
    }
    if (my $doi = $citation->doi) {
      my ($article) = $self->search_by_doi($doi, $citation->id || 0);
      return $article if defined $article;
    }
    if (my $asin = $citation->asin) {
      my ($article) = $self->search_by_asin($asin, $citation->id || 0);
      return $article if defined $article;
    }
  }
  return;
}

sub find_or_create_for_bookmark_and_citation {
  my ($self, $bookmark, $citation) = @_;
  if (defined (my $article = $self->find_for_bookmark_and_citation($bookmark, $citation))) {
    return $article;
  }
  return __PACKAGE__->create({hash => $bookmark->hash});
}

sub bookmarks {
  return Bibliotech::Bookmark->search_from_article(shift->id);
}

sub user_article_comments {
  return Bibliotech::User_Article_Comment->search_from_article(shift->id);
}

sub comments {
  return Bibliotech::Comment->search_from_article(shift->id);
}

1;
__END__
