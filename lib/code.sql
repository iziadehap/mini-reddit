-- ============================================
-- MINI REDDIT - COMPLETE SUPABASE SETUP
-- Version: Final with Notifications
-- ============================================

-- ============================================
-- 1. CREATE TABLES (in correct order)
-- ============================================

-- 1.1 profiles (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username text UNIQUE NOT NULL,
    full_name text,
    bio text,
    avatar_url text,
    banner_url text,
    karma integer DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 1.2 communities
CREATE TABLE IF NOT EXISTS public.communities (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text UNIQUE NOT NULL,
    description text,
    image_url text,
    banner_url text,
    created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 1.3 flairs
CREATE TABLE IF NOT EXISTS public.flairs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id uuid NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
    name text NOT NULL,
    color text DEFAULT '#808080',
    created_at timestamptz DEFAULT now()
);

-- 1.4 posts
CREATE TABLE IF NOT EXISTS public.posts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    community_id uuid NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
    flair_id uuid REFERENCES public.flairs(id) ON DELETE SET NULL,
    title text NOT NULL,
    content text,
    post_type text NOT NULL CHECK (post_type IN ('text', 'link', 'image')),
    link_url text,
    score integer DEFAULT 0,
    comments_count integer DEFAULT 0,
    is_deleted boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 1.5 post_images
CREATE TABLE IF NOT EXISTS public.post_images (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    image_url text NOT NULL,
    position integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- 1.6 post_votes
CREATE TABLE IF NOT EXISTS public.post_votes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    value smallint NOT NULL CHECK (value IN (1, -1)),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(post_id, user_id)
);

-- 1.7 comments
CREATE TABLE IF NOT EXISTS public.comments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content text NOT NULL,
    parent_id uuid REFERENCES public.comments(id) ON DELETE CASCADE,
    score integer DEFAULT 0,
    is_deleted boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 1.8 comment_votes
CREATE TABLE IF NOT EXISTS public.comment_votes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id uuid NOT NULL REFERENCES public.comments(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    value smallint NOT NULL CHECK (value IN (1, -1)),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(comment_id, user_id)
);

-- 1.9 saved_posts
CREATE TABLE IF NOT EXISTS public.saved_posts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    UNIQUE(user_id, post_id)
);

-- 1.10 followers
CREATE TABLE IF NOT EXISTS public.followers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    following_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    UNIQUE(follower_id, following_id)
);

-- 1.11 community_members
CREATE TABLE IF NOT EXISTS public.community_members (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id uuid NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role text DEFAULT 'member' CHECK (role IN ('member', 'admin')),
    joined_at timestamptz DEFAULT now(),
    UNIQUE(community_id, user_id)
);

-- 1.12 notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    actor_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('upvote', 'downvote', 'comment', 'reply', 'follow')),
    post_id uuid REFERENCES public.posts(id) ON DELETE CASCADE,
    comment_id uuid REFERENCES public.comments(id) ON DELETE CASCADE,
    is_read boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);

-- ============================================
-- 2. ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flairs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comment_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. RLS POLICIES
-- ============================================

-- 3.1 profiles policies
CREATE POLICY "Anyone can view profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 3.2 communities policies
CREATE POLICY "Anyone can view communities" ON public.communities FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create communities" ON public.communities FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Creator can update community" ON public.communities FOR UPDATE USING (created_by = auth.uid());
CREATE POLICY "Creator can delete community" ON public.communities FOR DELETE USING (created_by = auth.uid());

-- 3.3 flairs policies
CREATE POLICY "Anyone can view flairs" ON public.flairs FOR SELECT USING (true);
CREATE POLICY "Community admins can manage flairs" ON public.flairs FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.community_members 
        WHERE community_id = flairs.community_id 
        AND user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- 3.4 posts policies
CREATE POLICY "Anyone can view posts" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own posts" ON public.posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON public.posts FOR DELETE USING (auth.uid() = user_id);

-- 3.5 post_images policies
CREATE POLICY "Anyone can view post images" ON public.post_images FOR SELECT USING (true);
CREATE POLICY "Users can upload images to own posts" ON public.post_images FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.posts WHERE id = post_id AND user_id = auth.uid())
);

-- 3.6 post_votes policies
CREATE POLICY "Anyone can view votes" ON public.post_votes FOR SELECT USING (true);
CREATE POLICY "Users can vote on posts" ON public.post_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own votes" ON public.post_votes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own votes" ON public.post_votes FOR DELETE USING (auth.uid() = user_id);

-- 3.7 comments policies
CREATE POLICY "Anyone can view comments" ON public.comments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can comment" ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comments" ON public.comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = user_id);

-- 3.8 comment_votes policies
CREATE POLICY "Anyone can view comment votes" ON public.comment_votes FOR SELECT USING (true);
CREATE POLICY "Users can vote on comments" ON public.comment_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own votes" ON public.comment_votes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own votes" ON public.comment_votes FOR DELETE USING (auth.uid() = user_id);

-- 3.9 saved_posts policies
CREATE POLICY "Users can view own saved posts" ON public.saved_posts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can save posts" ON public.saved_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unsave posts" ON public.saved_posts FOR DELETE USING (auth.uid() = user_id);

-- 3.10 followers policies
CREATE POLICY "Anyone can view followers" ON public.followers FOR SELECT USING (true);
CREATE POLICY "Users can follow others" ON public.followers FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.followers FOR DELETE USING (auth.uid() = follower_id);

-- 3.11 community_members policies
CREATE POLICY "Anyone can view community members" ON public.community_members FOR SELECT USING (true);
CREATE POLICY "Users can join communities" ON public.community_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can leave communities" ON public.community_members FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage members" ON public.community_members FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM public.community_members 
        WHERE community_id = community_members.community_id 
        AND user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- 3.12 notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can mark notifications as read" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 4. TRIGGERS
-- ============================================

-- 4.1 Update post score on vote changes
CREATE OR REPLACE FUNCTION public.update_post_score()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_post_id uuid;
    v_new_score integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_post_id := OLD.post_id;
    ELSE
        v_post_id := NEW.post_id;
    END IF;
    
    SELECT COALESCE(SUM(value), 0) INTO v_new_score
    FROM public.post_votes
    WHERE post_id = v_post_id;
    
    UPDATE public.posts SET score = v_new_score, updated_at = now()
    WHERE id = v_post_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_post_votes_update_score ON public.post_votes;
CREATE TRIGGER trigger_post_votes_update_score
    AFTER INSERT OR UPDATE OR DELETE ON public.post_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_post_score();

-- 4.2 Update post comments count
CREATE OR REPLACE FUNCTION public.update_post_comments_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_post_id uuid;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_post_id := OLD.post_id;
    ELSE
        v_post_id := NEW.post_id;
    END IF;
    
    UPDATE public.posts 
    SET comments_count = (
        SELECT COUNT(*) FROM public.comments 
        WHERE post_id = v_post_id AND is_deleted = false
    )
    WHERE id = v_post_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_comments_update_count ON public.comments;
CREATE TRIGGER trigger_comments_update_count
    AFTER INSERT OR DELETE OR UPDATE OF is_deleted ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.update_post_comments_count();

-- 4.3 Update comment score on vote changes
CREATE OR REPLACE FUNCTION public.update_comment_score()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_comment_id uuid;
    v_new_score integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_comment_id := OLD.comment_id;
    ELSE
        v_comment_id := NEW.comment_id;
    END IF;
    
    SELECT COALESCE(SUM(value), 0) INTO v_new_score
    FROM public.comment_votes
    WHERE comment_id = v_comment_id;
    
    UPDATE public.comments SET score = v_new_score, updated_at = now()
    WHERE id = v_comment_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_comment_votes_update_score ON public.comment_votes;
CREATE TRIGGER trigger_comment_votes_update_score
    AFTER INSERT OR UPDATE OR DELETE ON public.comment_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_comment_score();

-- 4.4 Update user karma on post votes
CREATE OR REPLACE FUNCTION public.update_user_karma()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id uuid;
    v_karma_change integer;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT user_id INTO v_user_id FROM public.posts WHERE id = NEW.post_id;
        v_karma_change := NEW.value;
        UPDATE public.profiles SET karma = karma + v_karma_change, updated_at = now() WHERE id = v_user_id;
    ELSIF TG_OP = 'DELETE' THEN
        SELECT user_id INTO v_user_id FROM public.posts WHERE id = OLD.post_id;
        v_karma_change := -OLD.value;
        UPDATE public.profiles SET karma = karma + v_karma_change, updated_at = now() WHERE id = v_user_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.value != NEW.value THEN
        SELECT user_id INTO v_user_id FROM public.posts WHERE id = NEW.post_id;
        v_karma_change := NEW.value - OLD.value;
        UPDATE public.profiles SET karma = karma + v_karma_change, updated_at = now() WHERE id = v_user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_post_votes_update_karma ON public.post_votes;
CREATE TRIGGER trigger_post_votes_update_karma
    AFTER INSERT OR UPDATE OR DELETE ON public.post_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_user_karma();

-- 4.5 Update user karma on comment votes
CREATE OR REPLACE FUNCTION public.update_user_karma_from_comments()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id uuid;
    v_karma_change integer;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT user_id INTO v_user_id FROM public.comments WHERE id = NEW.comment_id;
        v_karma_change := NEW.value;
        UPDATE public.profiles SET karma = karma + v_karma_change, updated_at = now() WHERE id = v_user_id;
    ELSIF TG_OP = 'DELETE' THEN
        SELECT user_id INTO v_user_id FROM public.comments WHERE id = OLD.comment_id;
        v_karma_change := -OLD.value;
        UPDATE public.profiles SET karma = karma + v_karma_change, updated_at = now() WHERE id = v_user_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.value != NEW.value THEN
        SELECT user_id INTO v_user_id FROM public.comments WHERE id = NEW.comment_id;
        v_karma_change := NEW.value - OLD.value;
        UPDATE public.profiles SET karma = karma + v_karma_change, updated_at = now() WHERE id = v_user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_comment_votes_update_karma ON public.comment_votes;
CREATE TRIGGER trigger_comment_votes_update_karma
    AFTER INSERT OR UPDATE OR DELETE ON public.comment_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_user_karma_from_comments();
-- ============================================
-- 5. FUNCTIONS (CORRECTED)
-- ============================================

-- 5.1 Create Post (parameters with defaults at the end)
CREATE OR REPLACE FUNCTION public.create_post(
    p_user_id uuid,
    p_community_id uuid,
    p_title text,
    p_content text,
    p_post_type text,
    p_link_url text DEFAULT NULL,
    p_flair_id uuid DEFAULT NULL,
    p_image_urls text[] DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_post_id uuid;
    v_result jsonb;
    v_image_url text;
BEGIN
    IF LENGTH(TRIM(p_title)) = 0 THEN
        RETURN jsonb_build_object('success', false, 'message', 'Title cannot be empty');
    END IF;
    
    IF p_post_type = 'link' AND p_link_url IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Link URL required for link post');
    END IF;
    
    INSERT INTO public.posts (user_id, community_id, flair_id, title, content, post_type, link_url)
    VALUES (p_user_id, p_community_id, p_flair_id, TRIM(p_title), p_content, p_post_type, p_link_url)
    RETURNING id INTO v_post_id;
    
    IF p_image_urls IS NOT NULL AND array_length(p_image_urls, 1) > 0 THEN
        FOREACH v_image_url IN ARRAY p_image_urls LOOP
            INSERT INTO public.post_images (post_id, image_url)
            VALUES (v_post_id, v_image_url);
        END LOOP;
    END IF;
    
    SELECT jsonb_build_object(
        'success', true,
        'message', 'Post created successfully',
        'post_id', v_post_id
    ) INTO v_result;
    
    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'message', SQLERRM);
END;
$$;

-- 5.2 Vote on Post
CREATE OR REPLACE FUNCTION public.vote_post(
    p_post_id uuid,
    p_value integer,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_existing_value integer;
    v_post_owner_id uuid;
    v_action text;
    v_result_value integer;
BEGIN
    IF p_value NOT IN (1, -1) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid vote value');
    END IF;
    
    SELECT user_id INTO v_post_owner_id FROM public.posts WHERE id = p_post_id AND is_deleted = false;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'Post not found');
    END IF;
    
    IF v_post_owner_id = p_user_id THEN
        RETURN jsonb_build_object('success', false, 'message', 'You cannot vote on your own post');
    END IF;
    
    SELECT value INTO v_existing_value FROM public.post_votes WHERE post_id = p_post_id AND user_id = p_user_id;
    
    IF v_existing_value IS NULL THEN
        INSERT INTO public.post_votes (post_id, user_id, value) VALUES (p_post_id, p_user_id, p_value);
        v_action := 'added';
        v_result_value := p_value;
        
        INSERT INTO public.notifications (user_id, actor_id, type, post_id)
        VALUES (v_post_owner_id, p_user_id, CASE WHEN p_value = 1 THEN 'upvote' ELSE 'downvote' END, p_post_id);
        
    ELSIF v_existing_value = p_value THEN
        DELETE FROM public.post_votes WHERE post_id = p_post_id AND user_id = p_user_id;
        v_action := 'removed';
        v_result_value := 0;
        
    ELSE
        UPDATE public.post_votes SET value = p_value, updated_at = now()
        WHERE post_id = p_post_id AND user_id = p_user_id;
        v_action := 'changed';
        v_result_value := p_value;
    END IF;
    
    RETURN jsonb_build_object(
        'success', true, 'action', v_action, 'value', v_result_value
    );
END;
$$;

-- 5.3 Add Comment
CREATE OR REPLACE FUNCTION public.add_comment(
    p_post_id uuid,
    p_content text,
    p_user_id uuid,
    p_parent_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_comment_id uuid;
    v_post_owner_id uuid;
    v_parent_owner_id uuid;
BEGIN
    IF LENGTH(TRIM(p_content)) = 0 THEN
        RETURN jsonb_build_object('success', false, 'message', 'Comment cannot be empty');
    END IF;
    
    SELECT user_id INTO v_post_owner_id FROM public.posts WHERE id = p_post_id;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'Post not found');
    END IF;
    
    INSERT INTO public.comments (post_id, user_id, content, parent_id)
    VALUES (p_post_id, p_user_id, TRIM(p_content), p_parent_id)
    RETURNING id INTO v_comment_id;
    
    -- Send notification
    IF p_parent_id IS NULL THEN
        IF v_post_owner_id != p_user_id THEN
            INSERT INTO public.notifications (user_id, actor_id, type, post_id, comment_id)
            VALUES (v_post_owner_id, p_user_id, 'comment', p_post_id, v_comment_id);
        END IF;
    ELSE
        SELECT user_id INTO v_parent_owner_id FROM public.comments WHERE id = p_parent_id;
        IF v_parent_owner_id != p_user_id THEN
            INSERT INTO public.notifications (user_id, actor_id, type, post_id, comment_id)
            VALUES (v_parent_owner_id, p_user_id, 'reply', p_post_id, v_comment_id);
        END IF;
    END IF;
    
    RETURN jsonb_build_object('success', true, 'message', 'Comment added', 'comment_id', v_comment_id);
END;
$$;

-- 5.4 Vote on Comment
CREATE OR REPLACE FUNCTION public.vote_comment(
    p_comment_id uuid,
    p_value integer,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_existing_value integer;
    v_comment_owner_id uuid;
    v_action text;
    v_result_value integer;
BEGIN
    IF p_value NOT IN (1, -1) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid vote value');
    END IF;
    
    SELECT user_id INTO v_comment_owner_id FROM public.comments WHERE id = p_comment_id AND is_deleted = false;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'Comment not found');
    END IF;
    
    IF v_comment_owner_id = p_user_id THEN
        RETURN jsonb_build_object('success', false, 'message', 'You cannot vote on your own comment');
    END IF;
    
    SELECT value INTO v_existing_value FROM public.comment_votes WHERE comment_id = p_comment_id AND user_id = p_user_id;
    
    IF v_existing_value IS NULL THEN
        INSERT INTO public.comment_votes (comment_id, user_id, value) VALUES (p_comment_id, p_user_id, p_value);
        v_action := 'added';
        v_result_value := p_value;
        
        INSERT INTO public.notifications (user_id, actor_id, type, comment_id)
        VALUES (v_comment_owner_id, p_user_id, CASE WHEN p_value = 1 THEN 'upvote' ELSE 'downvote' END, p_comment_id);
        
    ELSIF v_existing_value = p_value THEN
        DELETE FROM public.comment_votes WHERE comment_id = p_comment_id AND user_id = p_user_id;
        v_action := 'removed';
        v_result_value := 0;
        
    ELSE
        UPDATE public.comment_votes SET value = p_value, updated_at = now()
        WHERE comment_id = p_comment_id AND user_id = p_user_id;
        v_action := 'changed';
        v_result_value := p_value;
    END IF;
    
    RETURN jsonb_build_object('success', true, 'action', v_action, 'value', v_result_value);
END;
$$;

-- 5.5 Follow User
CREATE OR REPLACE FUNCTION public.follow_user(
    p_follower_id uuid,
    p_following_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_follower_id = p_following_id THEN
        RETURN jsonb_build_object('success', false, 'message', 'You cannot follow yourself');
    END IF;
    
    IF EXISTS (SELECT 1 FROM public.followers WHERE follower_id = p_follower_id AND following_id = p_following_id) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Already following');
    END IF;
    
    INSERT INTO public.followers (follower_id, following_id) VALUES (p_follower_id, p_following_id);
    
    INSERT INTO public.notifications (user_id, actor_id, type)
    VALUES (p_following_id, p_follower_id, 'follow');
    
    RETURN jsonb_build_object('success', true, 'message', 'Followed successfully');
END;
$$;

-- 5.6 Unfollow User
CREATE OR REPLACE FUNCTION public.unfollow_user(
    p_follower_id uuid,
    p_following_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.followers WHERE follower_id = p_follower_id AND following_id = p_following_id;
    RETURN jsonb_build_object('success', true, 'message', 'Unfollowed successfully');
END;
$$;

-- 5.7 Save Post
CREATE OR REPLACE FUNCTION public.save_post(
    p_post_id uuid,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.saved_posts (user_id, post_id) VALUES (p_user_id, p_post_id)
    ON CONFLICT DO NOTHING;
    RETURN jsonb_build_object('success', true, 'message', 'Post saved');
END;
$$;

-- 5.8 Unsave Post
CREATE OR REPLACE FUNCTION public.unsave_post(
    p_post_id uuid,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.saved_posts WHERE user_id = p_user_id AND post_id = p_post_id;
    RETURN jsonb_build_object('success', true, 'message', 'Post unsaved');
END;
$$;

-- 5.9 Create Community
CREATE OR REPLACE FUNCTION public.create_community(
    p_name text,
    p_user_id uuid,
    p_description text DEFAULT NULL,
    p_image_url text DEFAULT NULL,
    p_banner_url text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_community_id uuid;
BEGIN
    IF LENGTH(p_name) < 3 THEN
        RETURN jsonb_build_object('success', false, 'message', 'Community name must be at least 3 characters');
    END IF;
    
    IF EXISTS (SELECT 1 FROM public.communities WHERE name = p_name) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Community name already exists');
    END IF;
    
    INSERT INTO public.communities (name, description, image_url, banner_url, created_by)
    VALUES (p_name, p_description, p_image_url, p_banner_url, p_user_id)
    RETURNING id INTO v_community_id;
    
    INSERT INTO public.community_members (community_id, user_id, role)
    VALUES (v_community_id, p_user_id, 'admin');
    
    RETURN jsonb_build_object('success', true, 'message', 'Community created', 'community_id', v_community_id);
END;
$$;
CREATE OR REPLACE FUNCTION public.get_community_details(
    p_community_id uuid,
    p_current_user_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_community jsonb;
    v_admins jsonb;
    v_stats jsonb;
    v_user_status jsonb;
BEGIN
    -- 1. Community data
    SELECT jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'description', c.description,
        'image_url', c.image_url,
        'banner_url', c.banner_url,
        'created_at', c.created_at,
        'created_by', c.created_by
    ) INTO v_community
    FROM public.communities c
    WHERE c.id = p_community_id;
    
    IF v_community IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Community not found');
    END IF;
    
    -- 2. Admins only (no online status)
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', p.id,
            'username', p.username,
            'avatar_url', p.avatar_url,
            'role', cm.role
        ) ORDER BY cm.joined_at
    ) INTO v_admins
    FROM public.community_members cm
    JOIN public.profiles p ON cm.user_id = p.id
    WHERE cm.community_id = p_community_id AND cm.role = 'admin';
    
    -- 3. Stats (members + posts only)
    SELECT jsonb_build_object(
        'members_count', (SELECT COUNT(*) FROM public.community_members WHERE community_id = p_community_id),
        'posts_count', (SELECT COUNT(*) FROM public.posts WHERE community_id = p_community_id AND is_deleted = false)
    ) INTO v_stats;
    
    -- 4. User status
    SELECT jsonb_build_object(
        'is_member', EXISTS(SELECT 1 FROM public.community_members WHERE community_id = p_community_id AND user_id = p_current_user_id),
        'is_admin', EXISTS(SELECT 1 FROM public.community_members WHERE community_id = p_community_id AND user_id = p_current_user_id AND role = 'admin'),
        'joined_at', (SELECT joined_at FROM public.community_members WHERE community_id = p_community_id AND user_id = p_current_user_id)
    ) INTO v_user_status;
    
    RETURN jsonb_build_object(
        'success', true,
        'community', v_community,
        'admins', COALESCE(v_admins, '[]'::jsonb),
        'stats', v_stats,
        'user_status', COALESCE(v_user_status, '{"is_member": false, "is_admin": false}'::jsonb)
    );
END;
$$;


-- ============================================
-- GET COMMUNITY POSTS (NEW FUNCTION)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_community_posts(
    p_community_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_sort_by text DEFAULT 'hot', -- 'hot', 'new', 'top'
    p_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    images jsonb,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.user_id AS author_id,
        pr.username AS author_username,
        pr.avatar_url AS author_avatar_url,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.comments_count,
        p.created_at,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.community_id = p_community_id AND p.is_deleted = false
    ORDER BY 
        CASE 
            WHEN p_sort_by = 'hot' THEN 
                p.score::double precision / POWER(GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0), 1.5)
            WHEN p_sort_by = 'top' THEN p.score::double precision
            ELSE EXTRACT(EPOCH FROM p.created_at)
        END DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- EDIT COMMUNITY (ADMIN ONLY)
-- ============================================

CREATE OR REPLACE FUNCTION public.edit_community(
    p_community_id uuid,
    p_user_id uuid,
    p_name text DEFAULT NULL,
    p_description text DEFAULT NULL,
    p_image_url text DEFAULT NULL,
    p_banner_url text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_is_admin boolean;
    v_current_name text;
    v_new_name text;
BEGIN
    -- 1. التحقق إن اليوزر أدمن في الكوميونيتي
    SELECT role = 'admin' INTO v_is_admin
    FROM public.community_members
    WHERE community_id = p_community_id AND user_id = p_user_id;
    
    IF NOT FOUND OR NOT v_is_admin THEN
        RETURN jsonb_build_object(
            'success', false, 
            'message', 'Unauthorized: Only admins can edit community'
        );
    END IF;
    
    -- 2. التحقق من الاسم الجديد لو متغير
    IF p_name IS NOT NULL THEN
        SELECT name INTO v_current_name 
        FROM public.communities 
        WHERE id = p_community_id;
        
        -- لو الاسم اتغير، نتأكد مفيش كوميونيتي تانية بنفس الاسم
        IF p_name != v_current_name THEN
            IF EXISTS (SELECT 1 FROM public.communities WHERE name = p_name AND id != p_community_id) THEN
                RETURN jsonb_build_object(
                    'success', false, 
                    'message', 'Community name already exists'
                );
            END IF;
            
            -- التحقق من طول الاسم
            IF LENGTH(TRIM(p_name)) < 3 THEN
                RETURN jsonb_build_object(
                    'success', false, 
                    'message', 'Community name must be at least 3 characters'
                );
            END IF;
            
            v_new_name := TRIM(p_name);
        END IF;
    END IF;
    
    -- 3. تنفيذ التحديث
    UPDATE public.communities
    SET 
        name = COALESCE(v_new_name, name),
        description = COALESCE(p_description, description),
        image_url = COALESCE(p_image_url, image_url),
        banner_url = COALESCE(p_banner_url, banner_url),
        updated_at = now()
    WHERE id = p_community_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Community updated successfully'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$;

-- 5.10 Join Community
CREATE OR REPLACE FUNCTION public.join_community(
    p_community_id uuid,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.community_members (community_id, user_id) VALUES (p_community_id, p_user_id)
    ON CONFLICT DO NOTHING;
    RETURN jsonb_build_object('success', true, 'message', 'Joined community');
END;
$$;

-- 5.11 Leave Community
CREATE OR REPLACE FUNCTION public.leave_community(
    p_community_id uuid,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role text;
BEGIN
    SELECT role INTO v_role FROM public.community_members WHERE community_id = p_community_id AND user_id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'Not a member');
    END IF;
    
    IF v_role = 'admin' THEN
        RETURN jsonb_build_object('success', false, 'message', 'Admins cannot leave. Transfer ownership first.');
    END IF;
    
    DELETE FROM public.community_members WHERE community_id = p_community_id AND user_id = p_user_id;
    RETURN jsonb_build_object('success', true, 'message', 'Left community');
END;
$$;

-- 5.12 Create Flair
CREATE OR REPLACE FUNCTION public.create_flair(
    p_community_id uuid,
    p_name text,
    p_color text DEFAULT '#808080'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_flair_id uuid;
BEGIN
    INSERT INTO public.flairs (community_id, name, color) VALUES (p_community_id, p_name, p_color)
    RETURNING id INTO v_flair_id;
    RETURN jsonb_build_object('success', true, 'message', 'Flair created', 'flair_id', v_flair_id);
END;
$$;

-- 5.13 Get Notifications
CREATE OR REPLACE FUNCTION public.get_notifications(
    p_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    actor_id uuid,
    actor_username text,
    actor_avatar_url text,
    type text,
    post_id uuid,
    comment_id uuid,
    is_read boolean,
    created_at timestamptz
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        n.id,
        n.actor_id,
        p.username as actor_username,
        p.avatar_url as actor_avatar_url,
        n.type,
        n.post_id,
        n.comment_id,
        n.is_read,
        n.created_at
    FROM public.notifications n
    JOIN public.profiles p ON n.actor_id = p.id
    WHERE n.user_id = p_user_id
    ORDER BY n.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- 5.14 Mark Notification as Read
CREATE OR REPLACE FUNCTION public.mark_notification_read(
    p_notification_id uuid,
    p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.notifications SET is_read = true
    WHERE id = p_notification_id AND user_id = p_user_id;
    RETURN jsonb_build_object('success', true);
END;
$$;
-- ============================================
-- 6. STORAGE BUCKETS
-- ============================================

INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('banners', 'banners', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('post_images', 'post_images', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('community_images', 'community_images', true) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 7. STORAGE POLICIES
-- ============================================

-- Avatars bucket policies
CREATE POLICY "Anyone can view avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Users can upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update own avatars" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Banners bucket policies
CREATE POLICY "Anyone can view banners" ON storage.objects FOR SELECT USING (bucket_id = 'banners');
CREATE POLICY "Users can upload banners" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'banners' AND auth.role() = 'authenticated');

-- Post images bucket policies
CREATE POLICY "Anyone can view post images" ON storage.objects FOR SELECT USING (bucket_id = 'post_images');
CREATE POLICY "Users can upload post images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'post_images' AND auth.role() = 'authenticated');

-- Community images bucket policies
CREATE POLICY "Anyone can view community images" ON storage.objects FOR SELECT USING (bucket_id = 'community_images');
CREATE POLICY "Community admins can upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'community_images' AND auth.role() = 'authenticated');

-- ============================================
-- 8. HELPER FUNCTIONS
-- ============================================

-- 8.1 Get User Profile
CREATE OR REPLACE FUNCTION public.get_user_profile(
    p_user_id uuid,
    p_current_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    username text,
    full_name text,
    bio text,
    avatar_url text,
    banner_url text,
    karma integer,
    followers_count bigint,
    following_count bigint,
    is_following boolean,
    created_at timestamptz
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        p.id,
        p.username,
        p.full_name,
        p.bio,
        p.avatar_url,
        p.banner_url,
        p.karma,
        (SELECT COUNT(*) FROM public.followers WHERE following_id = p.id)::bigint as followers_count,
        (SELECT COUNT(*) FROM public.followers WHERE follower_id = p.id)::bigint as following_count,
        EXISTS(SELECT 1 FROM public.followers WHERE follower_id = p_current_user_id AND following_id = p.id) as is_following,
        p.created_at
    FROM public.profiles p
    WHERE p.id = p_user_id;
$$;
-- ============================================
-- GET USER POSTS (UPDATED - matches FeedPostModel)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_user_posts(
    p_target_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_current_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    title text,
    content text,
    link_url text,
    post_type text,
    created_at timestamptz,
    score integer,
    hot_score double precision,
    comments_count integer,
    user_vote smallint,
    images jsonb,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_id uuid,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.created_at,
        p.score,
        p.score::double precision /
            POWER(
                GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0),
                1.5
            ) AS hot_score,
        p.comments_count,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_current_user_id LIMIT 1) AS user_vote,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        pr.id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.id AS flair_id,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.user_id = p_target_user_id AND p.is_deleted = false
    ORDER BY p.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- GET USER COMMENTS (profile activity)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_user_comments(
    p_target_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_current_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    content text,
    created_at timestamptz,
    score integer,
    post_id uuid,
    post_title text,
    community_name text,
    user_vote smallint
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        c.id,
        c.content,
        c.created_at,
        c.score,
        p.id AS post_id,
        p.title AS post_title,
        co.name AS community_name,
        (SELECT v.value FROM public.comment_votes v WHERE v.comment_id = c.id AND v.user_id = p_current_user_id LIMIT 1) AS user_vote
    FROM public.comments c
    JOIN public.posts p ON c.post_id = p.id
    JOIN public.communities co ON p.community_id = co.id
    WHERE c.user_id = p_target_user_id AND c.is_deleted = false AND p.is_deleted = false
    ORDER BY c.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- 8.3 Get Communities
CREATE OR REPLACE FUNCTION public.get_communities(
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_search text DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    name text,
    description text,
    image_url text,
    banner_url text,
    members_count bigint,
    created_at timestamptz,
    is_member boolean
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        c.id,
        c.name,
        c.description,
        c.image_url,
        c.banner_url,
        (SELECT COUNT(*) FROM public.community_members WHERE community_id = c.id)::bigint as members_count,
        c.created_at,
        EXISTS(SELECT 1 FROM public.community_members WHERE community_id = c.id AND user_id = auth.uid()) as is_member
    FROM public.communities c
    WHERE (p_search IS NULL OR c.name ILIKE '%' || p_search || '%')
    ORDER BY members_count DESC, c.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- 8.4 Get User Communities
CREATE OR REPLACE FUNCTION public.get_user_communities(
    p_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    name text,
    description text,
    image_url text,
    role text,
    joined_at timestamptz,
    members_count bigint
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        c.id,
        c.name,
        c.description,
        c.image_url,
        cm.role,
        cm.joined_at,
        (SELECT COUNT(*) FROM public.community_members WHERE community_id = c.id)::bigint as members_count
    FROM public.community_members cm
    JOIN public.communities c ON cm.community_id = c.id
    WHERE cm.user_id = p_user_id
    ORDER BY cm.joined_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- 8.5 Get Community Flairs
CREATE OR REPLACE FUNCTION public.get_community_flairs(
    p_community_id uuid
)
RETURNS TABLE (
    id uuid,
    name text,
    color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT id, name, color
    FROM public.flairs
    WHERE community_id = p_community_id
    ORDER BY name;
$$;

-- ============================================
-- 9. SEARCH FUNCTIONS
-- ============================================

-- 9.1 Search Users
CREATE OR REPLACE FUNCTION public.search_users(
    p_query text,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    username text,
    full_name text,
    avatar_url text,
    karma integer
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        id,
        username,
        full_name,
        avatar_url,
        karma
    FROM public.profiles
    WHERE username ILIKE '%' || p_query || '%'
       OR full_name ILIKE '%' || p_query || '%'
    ORDER BY username
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- 9.2 Get Saved Posts
CREATE OR REPLACE FUNCTION public.get_saved_posts(
    p_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    comments_count integer,
    created_at timestamptz,
    author_id uuid,
    author_username text,
    community_id uuid,
    community_name text
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        p.id,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.comments_count,
        p.created_at,
        p.user_id as author_id,
        pr.username as author_username,
        c.id as community_id,
        c.name as community_name
    FROM public.saved_posts sp
    JOIN public.posts p ON sp.post_id = p.id
    JOIN public.profiles pr ON p.user_id = pr.id
    JOIN public.communities c ON p.community_id = c.id
    WHERE sp.user_id = p_user_id AND p.is_deleted = false
    ORDER BY sp.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 10. FEED FUNCTIONS
-- ============================================
-- ============================================

-- ============================================
-- DROP ALL FUNCTIONS FIRST (to change return types)
-- ============================================

-- DROP FUNCTION IF EXISTS public.get_hot_feed(integer, integer, uuid, text[]);
-- DROP FUNCTION IF EXISTS public.get_new_feed(integer, integer, uuid, text[]);
-- DROP FUNCTION IF EXISTS public.get_top_feed(text, integer, integer, uuid, text[]);
-- DROP FUNCTION IF EXISTS public.get_best_feed(uuid, integer, integer);
-- DROP FUNCTION IF EXISTS public.search_posts(text, integer, integer, uuid, text[]);
-- DROP FUNCTION IF EXISTS public.get_popular_feed(integer, integer, uuid, text[]);
-- DROP FUNCTION IF EXISTS public.get_user_posts(uuid, integer, integer, uuid);
-- DROP FUNCTION IF EXISTS public.get_community_details(uuid, uuid);
-- DROP FUNCTION IF EXISTS public.edit_community(uuid, uuid, text, text, text, text);

-- ============================================
-- 1. GET HOT FEED (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_hot_feed(
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_user_id uuid DEFAULT NULL,
    p_community_names text[] DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    hot_score double precision,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.user_id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.score::double precision /
            POWER(
                GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0),
                1.5
            ) AS hot_score,
        p.comments_count,
        p.created_at,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
        EXISTS(SELECT 1 FROM public.saved_posts sp WHERE sp.post_id = p.id AND sp.user_id = p_user_id) AS is_saved,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.is_deleted = false
    AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
    ORDER BY hot_score DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 2. GET NEW FEED (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_new_feed(
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_user_id uuid DEFAULT NULL,
    p_community_names text[] DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.user_id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.comments_count,
        p.created_at,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
        EXISTS(SELECT 1 FROM public.saved_posts sp WHERE sp.post_id = p.id AND sp.user_id = p_user_id) AS is_saved,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.is_deleted = false
    AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
    ORDER BY p.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 3. GET TOP FEED (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_top_feed(
    p_timeframe text DEFAULT 'all',
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_user_id uuid DEFAULT NULL,
    p_community_names text[] DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.user_id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.comments_count,
        p.created_at,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
        EXISTS(SELECT 1 FROM public.saved_posts sp WHERE sp.post_id = p.id AND sp.user_id = p_user_id) AS is_saved,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.is_deleted = false
    AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
    AND CASE p_timeframe
        WHEN 'day' THEN p.created_at > NOW() - INTERVAL '1 day'
        WHEN 'week' THEN p.created_at > NOW() - INTERVAL '7 days'
        WHEN 'month' THEN p.created_at > NOW() - INTERVAL '30 days'
        WHEN 'year' THEN p.created_at > NOW() - INTERVAL '365 days'
        ELSE true
    END
    ORDER BY p.score DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 4. GET BEST FEED (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_best_feed(
    p_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    hot_score double precision,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT * FROM public.get_hot_feed(
        p_limit,
        p_offset,
        p_user_id,
        ARRAY(
            SELECT c.name 
            FROM public.community_members cm
            JOIN public.communities c ON cm.community_id = c.id
            WHERE cm.user_id = p_user_id
        )
    );
$$;

-- ============================================
-- 5. SEARCH POSTS (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.search_posts(
    p_query text,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_user_id uuid DEFAULT NULL,
    p_community_names text[] DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_name text,
    flair_color text,
    relevance double precision
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.user_id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.comments_count,
        p.created_at,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
        EXISTS(SELECT 1 FROM public.saved_posts sp WHERE sp.post_id = p.id AND sp.user_id = p_user_id) AS is_saved,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.name AS flair_name,
        f.color AS flair_color,
        ts_rank(to_tsvector('english', p.title || ' ' || COALESCE(p.content, '')), plainto_tsquery('english', p_query)) AS relevance
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.is_deleted = false
    AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
    AND (p.title ILIKE '%' || p_query || '%' OR p.content ILIKE '%' || p_query || '%')
    ORDER BY relevance DESC, p.score DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 6. GET POPULAR FEED (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_popular_feed(
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_user_id uuid DEFAULT NULL,
    p_community_names text[] DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    title text,
    content text,
    link_url text,
    post_type text,
    score integer,
    hot_score double precision,
    comments_count integer,
    created_at timestamptz,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.user_id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.score,
        p.score::double precision /
            POWER(
                GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0),
                1.5
            ) AS hot_score,
        p.comments_count,
        p.created_at,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
        EXISTS(SELECT 1 FROM public.saved_posts sp WHERE sp.post_id = p.id AND sp.user_id = p_user_id) AS is_saved,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.is_deleted = false
    AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
    ORDER BY hot_score DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 7. GET USER POSTS (with is_saved)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_user_posts(
    p_target_user_id uuid,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0,
    p_current_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    title text,
    content text,
    link_url text,
    post_type text,
    created_at timestamptz,
    score integer,
    hot_score double precision,
    comments_count integer,
    user_vote smallint,
    is_saved boolean,
    images jsonb,
    author_id uuid,
    author_username text,
    author_full_name text,
    author_avatar_url text,
    community_id uuid,
    community_name text,
    community_image_url text,
    flair_id uuid,
    flair_name text,
    flair_color text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.title,
        p.content,
        p.link_url,
        p.post_type,
        p.created_at,
        p.score,
        p.score::double precision /
            POWER(
                GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0),
                1.5
            ) AS hot_score,
        p.comments_count,
        (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_current_user_id LIMIT 1) AS user_vote,
        EXISTS(SELECT 1 FROM public.saved_posts sp WHERE sp.post_id = p.id AND sp.user_id = p_current_user_id) AS is_saved,
        (SELECT jsonb_agg(
            jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
            ORDER BY pi.position
         ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
        pr.id AS author_id,
        pr.username AS author_username,
        pr.full_name AS author_full_name,
        pr.avatar_url AS author_avatar_url,
        c.id AS community_id,
        c.name AS community_name,
        c.image_url AS community_image_url,
        f.id AS flair_id,
        f.name AS flair_name,
        f.color AS flair_color
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    LEFT JOIN public.communities c ON p.community_id = c.id
    LEFT JOIN public.flairs f ON p.flair_id = f.id
    WHERE p.user_id = p_target_user_id AND p.is_deleted = false
    ORDER BY p.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

-- ============================================
-- 8. GET COMMUNITY DETAILS (clean - no online)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_community_details(
    p_community_id uuid,
    p_current_user_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_community jsonb;
    v_admins jsonb;
    v_stats jsonb;
    v_user_status jsonb;
BEGIN
    -- 1. Community data
    SELECT jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'description', c.description,
        'image_url', c.image_url,
        'banner_url', c.banner_url,
        'created_at', c.created_at,
        'created_by', c.created_by
    ) INTO v_community
    FROM public.communities c
    WHERE c.id = p_community_id;
    
    IF v_community IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Community not found');
    END IF;
    
    -- 2. Admins only
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', p.id,
            'username', p.username,
            'avatar_url', p.avatar_url,
            'role', cm.role
        ) ORDER BY cm.joined_at
    ) INTO v_admins
    FROM public.community_members cm
    JOIN public.profiles p ON cm.user_id = p.id
    WHERE cm.community_id = p_community_id AND cm.role = 'admin';
    
    -- 3. Stats (members + posts only)
    SELECT jsonb_build_object(
        'members_count', (SELECT COUNT(*) FROM public.community_members WHERE community_id = p_community_id),
        'posts_count', (SELECT COUNT(*) FROM public.posts WHERE community_id = p_community_id AND is_deleted = false)
    ) INTO v_stats;
    
    -- 4. User status
    SELECT jsonb_build_object(
        'is_member', EXISTS(SELECT 1 FROM public.community_members WHERE community_id = p_community_id AND user_id = p_current_user_id),
        'is_admin', EXISTS(SELECT 1 FROM public.community_members WHERE community_id = p_community_id AND user_id = p_current_user_id AND role = 'admin'),
        'joined_at', (SELECT joined_at FROM public.community_members WHERE community_id = p_community_id AND user_id = p_current_user_id)
    ) INTO v_user_status;
    
    RETURN jsonb_build_object(
        'success', true,
        'community', v_community,
        'admins', COALESCE(v_admins, '[]'::jsonb),
        'stats', v_stats,
        'user_status', COALESCE(v_user_status, '{"is_member": false, "is_admin": false}'::jsonb)
    );
END;
$$;

-- ============================================
-- 9. EDIT COMMUNITY (admin only)
-- ============================================

CREATE OR REPLACE FUNCTION public.edit_community(
    p_community_id uuid,
    p_user_id uuid,
    p_name text DEFAULT NULL,
    p_description text DEFAULT NULL,
    p_image_url text DEFAULT NULL,
    p_banner_url text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_is_admin boolean;
    v_current_name text;
    v_new_name text;
BEGIN
    -- 1. Check if user is admin
    SELECT role = 'admin' INTO v_is_admin
    FROM public.community_members
    WHERE community_id = p_community_id AND user_id = p_user_id;
    
    IF NOT FOUND OR NOT v_is_admin THEN
        RETURN jsonb_build_object(
            'success', false, 
            'message', 'Unauthorized: Only admins can edit community'
        );
    END IF;
    
    -- 2. Validate name if changed
    IF p_name IS NOT NULL THEN
        SELECT name INTO v_current_name 
        FROM public.communities 
        WHERE id = p_community_id;
        
        IF p_name != v_current_name THEN
            IF EXISTS (SELECT 1 FROM public.communities WHERE name = p_name AND id != p_community_id) THEN
                RETURN jsonb_build_object(
                    'success', false, 
                    'message', 'Community name already exists'
                );
            END IF;
            
            IF LENGTH(TRIM(p_name)) < 3 THEN
                RETURN jsonb_build_object(
                    'success', false, 
                    'message', 'Community name must be at least 3 characters'
                );
            END IF;
            
            v_new_name := TRIM(p_name);
        END IF;
    END IF;
    
    -- 3. Update
    UPDATE public.communities
    SET 
        name = COALESCE(v_new_name, name),
        description = COALESCE(p_description, description),
        image_url = COALESCE(p_image_url, image_url),
        banner_url = COALESCE(p_banner_url, banner_url),
        updated_at = now()
    WHERE id = p_community_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Community updated successfully'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$;

-- ============================================
-- END
-- ============================================

-- ============================================
-- CREATE UPDATED FEED FUNCTIONS (WITH IMAGES)
-- ============================================

-- -- 10.1 Get Hot Feed (with images)
-- CREATE OR REPLACE FUNCTION public.get_hot_feed(
--     p_limit integer DEFAULT 20,
--     p_offset integer DEFAULT 0,
--     p_user_id uuid DEFAULT NULL,
--     p_community_names text[] DEFAULT NULL
-- )
-- RETURNS TABLE (
--     id uuid,
--     author_id uuid,
--     author_username text,
--     author_full_name text,
--     author_avatar_url text,
--     title text,
--     content text,
--     link_url text,
--     post_type text,
--     score integer,
--     hot_score double precision,
--     comments_count integer,
--     created_at timestamptz,
--     user_vote smallint,
--     images jsonb,
--     community_id uuid,
--     community_name text,
--     community_image_url text,
--     flair_name text,
--     flair_color text
-- )
-- LANGUAGE sql
-- STABLE
-- AS $$
--     SELECT
--         p.id,
--         p.user_id AS author_id,
--         pr.username AS author_username,
--         pr.full_name AS author_full_name,
--         pr.avatar_url AS author_avatar_url,
--         p.title,
--         p.content,
--         p.link_url,
--         p.post_type,
--         p.score,
--         p.score::double precision /
--             POWER(
--                 GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0),
--                 1.5
--             ) AS hot_score,
--         p.comments_count,
--         p.created_at,
--         (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
--         (SELECT jsonb_agg(
--             jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
--             ORDER BY pi.position
--          ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
--         c.id AS community_id,
--         c.name AS community_name,
--         c.image_url AS community_image_url,
--         f.name AS flair_name,
--         f.color AS flair_color
--     FROM public.posts p
--     LEFT JOIN public.profiles pr ON p.user_id = pr.id
--     LEFT JOIN public.communities c ON p.community_id = c.id
--     LEFT JOIN public.flairs f ON p.flair_id = f.id
--     WHERE p.is_deleted = false
--     AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
--     ORDER BY hot_score DESC
--     LIMIT p_limit
--     OFFSET p_offset;
-- $$;
--
-- -- 10.2 Get New Feed (with images)
-- CREATE OR REPLACE FUNCTION public.get_new_feed(
--     p_limit integer DEFAULT 20,
--     p_offset integer DEFAULT 0,
--     p_user_id uuid DEFAULT NULL,
--     p_community_names text[] DEFAULT NULL
-- )
-- RETURNS TABLE (
--     id uuid,
--     author_id uuid,
--     author_username text,
--     author_full_name text,
--     author_avatar_url text,
--     title text,
--     content text,
--     link_url text,
--     post_type text,
--     score integer,
--     comments_count integer,
--     created_at timestamptz,
--     user_vote smallint,
--     images jsonb,
--     community_id uuid,
--     community_name text,
--     community_image_url text,
--     flair_name text,
--     flair_color text
-- )
-- LANGUAGE sql
-- STABLE
-- AS $$
--     SELECT
--         p.id,
--         p.user_id AS author_id,
--         pr.username AS author_username,
--         pr.full_name AS author_full_name,
--         pr.avatar_url AS author_avatar_url,
--         p.title,
--         p.content,
--         p.link_url,
--         p.post_type,
--         p.score,
--         p.comments_count,
--         p.created_at,
--         (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
--         (SELECT jsonb_agg(
--             jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
--             ORDER BY pi.position
--          ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
--         c.id AS community_id,
--         c.name AS community_name,
--         c.image_url AS community_image_url,
--         f.name AS flair_name,
--         f.color AS flair_color
--     FROM public.posts p
--     LEFT JOIN public.profiles pr ON p.user_id = pr.id
--     LEFT JOIN public.communities c ON p.community_id = c.id
--     LEFT JOIN public.flairs f ON p.flair_id = f.id
--     WHERE p.is_deleted = false
--     AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
--     ORDER BY p.created_at DESC
--     LIMIT p_limit
--     OFFSET p_offset;
-- $$;

-- -- 10.3 Get Top Feed (with images)
-- CREATE OR REPLACE FUNCTION public.get_top_feed(
--     p_timeframe text DEFAULT 'all',
--     p_limit integer DEFAULT 20,
--     p_offset integer DEFAULT 0,
--     p_user_id uuid DEFAULT NULL,
--     p_community_names text[] DEFAULT NULL
-- )
-- RETURNS TABLE (
--     id uuid,
--     author_id uuid,
--     author_username text,
--     author_full_name text,
--     author_avatar_url text,
--     title text,
--     content text,
--     link_url text,
--     post_type text,
--     score integer,
--     comments_count integer,
--     created_at timestamptz,
--     user_vote smallint,
--     images jsonb,
--     community_id uuid,
--     community_name text,
--     community_image_url text,
--     flair_name text,
--     flair_color text
-- )
-- LANGUAGE sql
-- STABLE
-- AS $$
--     SELECT
--         p.id,
--         p.user_id AS author_id,
--         pr.username AS author_username,
--         pr.full_name AS author_full_name,
--         pr.avatar_url AS author_avatar_url,
--         p.title,
--         p.content,
--         p.link_url,
--         p.post_type,
--         p.score,
--         p.comments_count,
--         p.created_at,
--         (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
--         (SELECT jsonb_agg(
--             jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
--             ORDER BY pi.position
--          ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
--         c.id AS community_id,
--         c.name AS community_name,
--         c.image_url AS community_image_url,
--         f.name AS flair_name,
--         f.color AS flair_color
--     FROM public.posts p
--     LEFT JOIN public.profiles pr ON p.user_id = pr.id
--     LEFT JOIN public.communities c ON p.community_id = c.id
--     LEFT JOIN public.flairs f ON p.flair_id = f.id
--     WHERE p.is_deleted = false
--     AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
--     AND CASE p_timeframe
--         WHEN 'day' THEN p.created_at > NOW() - INTERVAL '1 day'
--         WHEN 'week' THEN p.created_at > NOW() - INTERVAL '7 days'
--         WHEN 'month' THEN p.created_at > NOW() - INTERVAL '30 days'
--         WHEN 'year' THEN p.created_at > NOW() - INTERVAL '365 days'
--         ELSE true
--     END
--     ORDER BY p.score DESC
--     LIMIT p_limit
--     OFFSET p_offset;
-- $$;
--
-- -- 10.4 Get Best Feed (calls get_hot_feed, no changes needed)
-- CREATE OR REPLACE FUNCTION public.get_best_feed(
--     p_user_id uuid,
--     p_limit integer DEFAULT 20,
--     p_offset integer DEFAULT 0
-- )
-- RETURNS TABLE (
--     id uuid,
--     author_id uuid,
--     author_username text,
--     author_full_name text,
--     author_avatar_url text,
--     title text,
--     content text,
--     link_url text,
--     post_type text,
--     score integer,
--     hot_score double precision,
--     comments_count integer,
--     created_at timestamptz,
--     user_vote smallint,
--     images jsonb,
--     community_id uuid,
--     community_name text,
--     community_image_url text,
--     flair_name text,
--     flair_color text
-- )
-- LANGUAGE sql
-- STABLE
-- AS $$
--     SELECT * FROM public.get_hot_feed(
--         p_limit,
--         p_offset,
--         p_user_id,
--         ARRAY(
--             SELECT c.name 
--             FROM public.community_members cm
--             JOIN public.communities c ON cm.community_id = c.id
--             WHERE cm.user_id = p_user_id
--         )
--     );
-- $$;
--
-- 10.5 Search Posts (with images)
-- CREATE OR REPLACE FUNCTION public.search_posts(
--     p_query text,
--     p_limit integer DEFAULT 20,
--     p_offset integer DEFAULT 0,
--     p_user_id uuid DEFAULT NULL,
--     p_community_names text[] DEFAULT NULL
-- )
-- RETURNS TABLE (
--     id uuid,
--     author_id uuid,
--     author_username text,
--     author_full_name text,
--     author_avatar_url text,
--     title text,
--     content text,
--     link_url text,
--     post_type text,
--     score integer,
--     comments_count integer,
--     created_at timestamptz,
--     user_vote smallint,
--     images jsonb,
--     community_id uuid,
--     community_name text,
--     community_image_url text,
--     flair_name text,
--     flair_color text,
--     relevance double precision
-- )
-- LANGUAGE sql
-- STABLE
-- AS $$
--     SELECT
--         p.id,
--         p.user_id AS author_id,
--         pr.username AS author_username,
--         pr.full_name AS author_full_name,
--         pr.avatar_url AS author_avatar_url,
--         p.title,
--         p.content,
--         p.link_url,
--         p.post_type,
--         p.score,
--         p.comments_count,
--         p.created_at,
--         (SELECT v.value FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = p_user_id LIMIT 1) AS user_vote,
--         (SELECT jsonb_agg(
--             jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
--             ORDER BY pi.position
--          ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
--         c.id AS community_id,
--         c.name AS community_name,
--         c.image_url AS community_image_url,
--         f.name AS flair_name,
--         f.color AS flair_color,
--         ts_rank(to_tsvector('english', p.title || ' ' || COALESCE(p.content, '')), plainto_tsquery('english', p_query)) AS relevance
--     FROM public.posts p
--     LEFT JOIN public.profiles pr ON p.user_id = pr.id
--     LEFT JOIN public.communities c ON p.community_id = c.id
--     LEFT JOIN public.flairs f ON p.flair_id = f.id
--     WHERE p.is_deleted = false
--     AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
--     AND (p.title ILIKE '%' || p_query || '%' OR p.content ILIKE '%' || p_query || '%')
--     ORDER BY relevance DESC, p.score DESC
--     LIMIT p_limit
--     OFFSET p_offset;
-- $$;

-- -- 10.6 Get Popular Feed (with images)
-- CREATE OR REPLACE FUNCTION public.get_popular_feed(
--     p_limit integer DEFAULT 20,
--     p_offset integer DEFAULT 0,
--     p_community_names text[] DEFAULT NULL
-- )
-- RETURNS TABLE (
--     id uuid,
--     author_id uuid,
--     author_username text,
--     author_full_name text,
--     author_avatar_url text,
--     title text,
--     content text,
--     link_url text,
--     post_type text,
--     score integer,
--     hot_score double precision,
--     comments_count integer,
--     created_at timestamptz,
--     images jsonb,
--     community_id uuid,
--     community_name text,
--     community_image_url text,
--     flair_name text,
--     flair_color text
-- )
-- LANGUAGE sql
-- STABLE
-- AS $$
--     SELECT
--         p.id,
--         p.user_id AS author_id,
--         pr.username AS author_username,
--         pr.full_name AS author_full_name,
--         pr.avatar_url AS author_avatar_url,
--         p.title,
--         p.content,
--         p.link_url,
--         p.post_type,
--         p.score,
--         p.score::double precision /
--             POWER(
--                 GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 + 2, 2.0),
--                 1.5
--             ) AS hot_score,
--         p.comments_count,
--         p.created_at,
--         (SELECT jsonb_agg(
--             jsonb_build_object('id', pi.id, 'url', pi.image_url, 'position', pi.position)
--             ORDER BY pi.position
--          ) FROM public.post_images pi WHERE pi.post_id = p.id) AS images,
--         c.id AS community_id,
--         c.name AS community_name,
--         c.image_url AS community_image_url,
--         f.name AS flair_name,
--         f.color AS flair_color
--     FROM public.posts p
--     LEFT JOIN public.profiles pr ON p.user_id = pr.id
--     LEFT JOIN public.communities c ON p.community_id = c.id
--     LEFT JOIN public.flairs f ON p.flair_id = f.id
--     WHERE p.is_deleted = false
--     AND (p_community_names IS NULL OR c.name = ANY(p_community_names))
--     ORDER BY hot_score DESC
--     LIMIT p_limit
--     OFFSET p_offset;
-- $$;

-- ============================================
-- END OF SETUP
-- ============================================