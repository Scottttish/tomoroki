-- =====================================================
-- Tomoroki Supabase Migration
-- Execute this SQL in Supabase Dashboard → SQL Editor
-- =====================================================

-- 1. CHATS TABLE
CREATE TABLE IF NOT EXISTS public.chats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT,
  type TEXT NOT NULL DEFAULT 'private' CHECK (type IN ('private', 'group')),
  team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CHAT PARTICIPANTS TABLE
CREATE TABLE IF NOT EXISTS public.chat_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  last_read_at TIMESTAMPTZ,
  UNIQUE(chat_id, user_id)
);

-- 3. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'image', 'file', 'voice', 'system')),
  file_url TEXT,
  file_name TEXT,
  reply_to_id UUID REFERENCES public.messages(id) ON DELETE SET NULL,
  is_edited BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. FRIENDSHIPS TABLE
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- 5. TASK VISIBILITY TABLE
CREATE TABLE IF NOT EXISTS public.task_visibility (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(task_id, user_id)
);

-- 6. ALTER subtasks: add completed_by column
ALTER TABLE public.subtasks ADD COLUMN IF NOT EXISTS completed_by UUID REFERENCES public.users(id) ON DELETE SET NULL;

-- 7. Ensure team_members role values are correct
-- (owner, editor, member instead of admin)
-- Note: existing 'admin' values should be updated to 'owner'
UPDATE public.team_members SET role = 'owner' WHERE role = 'admin';

-- 8. INDEXES for performance
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON public.messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id ON public.chat_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_chat_id ON public.chat_participants(chat_id);
CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON public.friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON public.friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_task_visibility_task_id ON public.task_visibility(task_id);
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_team_id ON public.tasks(team_id);
CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON public.subtasks(task_id);

-- 9. ENABLE REALTIME for messages (for live chat)
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chats;

-- 10. RLS POLICIES (basic - adjust as needed)
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_visibility ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to access their own data
CREATE POLICY "Users can view their chats" ON public.chats
  FOR SELECT USING (
    id IN (SELECT chat_id FROM public.chat_participants WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can create chats" ON public.chats
  FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can view their chat participants" ON public.chat_participants
  FOR SELECT USING (
    chat_id IN (SELECT chat_id FROM public.chat_participants WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can join chats" ON public.chat_participants
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view messages in their chats" ON public.messages
  FOR SELECT USING (
    chat_id IN (SELECT chat_id FROM public.chat_participants WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can send messages" ON public.messages
  FOR INSERT WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Users can update own messages" ON public.messages
  FOR UPDATE USING (sender_id = auth.uid());

CREATE POLICY "Users can manage own friendships" ON public.friendships
  FOR ALL USING (user_id = auth.uid() OR friend_id = auth.uid());

CREATE POLICY "Users can view task visibility" ON public.task_visibility
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Task owners can manage visibility" ON public.task_visibility
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Task owners can delete visibility" ON public.task_visibility
  FOR DELETE USING (true);
