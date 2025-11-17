# Component Structure Rules

These rules apply to ALL frontend React/Next.js components.

## File Organization

**Component location**:
```
components/
├── ui/              # shadcn/ui components (managed)
├── layout/          # Layout components (Header, Footer, etc.)
├── features/        # Feature-specific components
└── shared/          # Shared utility components
```

**One component per file**:
```typescript
// Good: components/features/UserProfile.tsx
export function UserProfile() { ... }

// Bad: components/Users.tsx with UserProfile, UserCard, UserList
```

## Component Structure

**Use this template**:
```typescript
"use client"; // Only if needed (hooks, events)

import { ... } from "...";

// Types first
interface ComponentProps {
  prop1: string;
  prop2?: number;
}

// Component
export function Component({ prop1, prop2 }: ComponentProps) {
  // Hooks
  const [state, setState] = useState();

  // Event handlers
  const handleClick = () => { ... };

  // Render
  return (
    <div>
      {/* JSX */}
    </div>
  );
}
```

## Naming Conventions

**Components**: PascalCase
```typescript
// Good
export function UserProfile() { ... }

// Bad
export function userProfile() { ... }
export function user_profile() { ... }
```

**Props interfaces**: ComponentNameProps
```typescript
interface UserProfileProps {
  userId: string;
}
```

**Event handlers**: handle + EventName
```typescript
const handleClick = () => { ... };
const handleSubmit = () => { ... };
```

## Server vs Client Components

**Default to Server Components**:
```typescript
// app/posts/page.tsx - Server Component (default)
export default async function PostsPage() {
  const posts = await fetchPosts(); // Can await directly
  return <div>{...}</div>;
}
```

**Use Client only when needed**:
```typescript
// components/LikeButton.tsx - Client Component
"use client";

export function LikeButton() {
  const [liked, setLiked] = useState(false); // Needs useState
  return <button onClick={() => setLiked(!liked)}>...</button>;
}
```

## Props Destructuring

**Always destructure props**:
```typescript
// Good
export function User({ name, email }: UserProps) {
  return <div>{name}</div>;
}

// Bad
export function User(props: UserProps) {
  return <div>{props.name}</div>;
}
```

## shadcn/ui Usage

**ALWAYS use shadcn/ui components** instead of custom ones:
```typescript
// Good
import { Button } from "@/components/ui/button";
<Button variant="destructive">Delete</Button>

// Bad
<button className="bg-red-500 ...">Delete</button>
```

## TypeScript

**No implicit any**:
```typescript
// Good
function handleSubmit(event: React.FormEvent) { ... }

// Bad
function handleSubmit(event) { ... } // implicit any
```

**Use proper types for children**:
```typescript
interface LayoutProps {
  children: React.ReactNode; // Not JSX.Element
}
```
