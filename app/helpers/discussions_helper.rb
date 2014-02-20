module DiscussionsHelper
  include Twitter::Extractor
  include Twitter::Autolink

  def no_discussions_available?
    (@discussion_readers_with_open_motions.size + @discussion_readers_without_open_motions.size) == 0
  end

  def enough_activity_for_jump_link?
    @discussion.items_count > 3
  end

  def path_of_latest_activity
    if current_page == @discussion_reader.first_unread_page
      '#latest-activity'.html_safe
    else
      discussion_path(@discussion, page: @discussion_reader.first_unread_page, anchor: 'latest-activity')
    end
  end

  def path_of_add_comment
    if current_page == @discussion_reader.first_unread_page
      '#comment-input'
    else
      if actual_total_pages == 1
        discussion_path(@discussion, anchor: 'comment-input')
      else
        discussion_path(@discussion, page: actual_total_pages, anchor: 'comment-input')
      end
    end
  end

  def css_classes_for_discussion_preview(discussion, discussion_reader)
    class_names = []
    class_names << 'showing-group' unless @group == discussion.group
    class_names << 'unread' if discussion_reader.unread_content_exists?
    class_names.join(' ')
  end

  def add_mention_links(comment)
    auto_link_usernames_or_lists(comment, :username_url_base => "#", :username_include_symbol => true)
  end

  def css_for_markdown_link(target, setting)
    return "icon-ok" if (target.uses_markdown == setting)
  end

  def markdown_img(uses_markdown)
    if uses_markdown
      image_tag("markdown_on.png", class: 'markdown-icon markdown-on')
    else
      image_tag("markdown_off.png", class: 'markdown-icon markdown-off')
    end
  end

  def last_page?
    actual_total_pages == current_page
  end

  def actual_total_pages
    if @activity.total_pages == 0
      1
    else
      @activity.total_pages
    end
  end

  def current_page
    @current_page ||= requested_or_first_unread_page
  end

  def requested_or_first_unread_page
    if params[:page]
      params[:page].to_i
    else
      @discussion_reader.first_unread_page
    end
  end

  def user_has_not_read_event?(event)
    if @discussion_reader and @discussion_reader.last_read_at.present?
      if event.belongs_to?(current_user)
        false
      else
        @discussion_reader.last_read_at < event.updated_at
      end
    else
      false
    end
  end

  def discussion_privacy_options(discussion)
    options = []
    group =
      if discussion.group_id
        t(:'simple_form.labels.discussion.of') + discussion.group.name
      else
        t :'simple_form.labels.discussion.of_no_group'
      end
    icon =
    header = t "simple_form.labels.discussion.privacy_public_header"
    description = t 'simple_form.labels.discussion.privacy_public_description'
    options << ["<span class='discussion-privacy-setting-header'><i class='icon-globe'></i>#{header}<br /><p>#{description}</p>".html_safe, false]

    header = t "simple_form.labels.discussion.privacy_private_header"
    description = t(:'simple_form.labels.discussion.privacy_private_description', group: group)
    options << ["<span class='discussion-privacy-setting-header'><i class='icon-lock'></i>#{header}<br /><p>#{description}</p>".html_safe, true ]
  end

  def current_language
    Translation.language I18n.locale.to_s
  end

  def privacy_language(discussion)
    discussion.private? ? "private" : "public"
  end

  def privacy_icon(discussion)
    discussion.private? ? "lock" : "globe"
  end
end
