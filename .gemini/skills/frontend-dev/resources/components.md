# shadcn/ui Component Patterns

## Core UI Components

### Button Patterns

```typescript
import { Button } from "@/components/ui/button";
import { Loader2, Mail, Download } from "lucide-react";

export function ButtonExamples() {
  return (
    <div className="flex flex-wrap gap-4">
      {/* Basic variants */}
      <Button>Default</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="destructive">Destructive</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="link">Link</Button>

      {/* With icons */}
      <Button>
        <Mail className="mr-2 h-4 w-4" />
        Login with Email
      </Button>

      {/* Loading state */}
      <Button disabled>
        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
        Please wait
      </Button>

      {/* Icon only */}
      <Button size="icon">
        <Download className="h-4 w-4" />
      </Button>

      {/* As child (custom element) */}
      <Button asChild>
        <a href="/dashboard">Go to Dashboard</a>
      </Button>
    </div>
  );
}
```

### Card Patterns

```typescript
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

export function PostCard({ post }: { post: Post }) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-start justify-between">
          <div>
            <CardTitle>{post.title}</CardTitle>
            <CardDescription>
              Posted by {post.author} • {formatDate(post.createdAt)}
            </CardDescription>
          </div>
          <Badge variant={post.published ? "default" : "secondary"}>
            {post.published ? "Published" : "Draft"}
          </Badge>
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-sm text-muted-foreground">{post.excerpt}</p>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="ghost" size="sm">View</Button>
        <div className="space-x-2">
          <Button variant="outline" size="sm">Edit</Button>
          <Button variant="destructive" size="sm">Delete</Button>
        </div>
      </CardFooter>
    </Card>
  );
}
```

### Dialog Patterns

```typescript
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState } from "react";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function CreateItemDialog() {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const createItem = useMutation(api.items.create);

  const handleSubmit = async () => {
    await createItem({ name });
    setName("");
    setOpen(false);
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>Create New Item</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create Item</DialogTitle>
          <DialogDescription>
            Add a new item to your collection.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid gap-2">
            <Label htmlFor="name">Name</Label>
            <Input
              id="name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter item name"
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <Button onClick={handleSubmit}>Create</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

### Sheet (Sidebar) Pattern

```typescript
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Menu } from "lucide-react";

export function MobileNav() {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon">
          <Menu className="h-6 w-6" />
        </Button>
      </SheetTrigger>
      <SheetContent side="left">
        <SheetHeader>
          <SheetTitle>Navigation</SheetTitle>
          <SheetDescription>
            Browse through the app
          </SheetDescription>
        </SheetHeader>
        <nav className="flex flex-col gap-4 mt-4">
          <a href="/dashboard" className="text-lg">Dashboard</a>
          <a href="/posts" className="text-lg">Posts</a>
          <a href="/settings" className="text-lg">Settings</a>
        </nav>
      </SheetContent>
    </Sheet>
  );
}
```

## Data Display Components

### Table Pattern

```typescript
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { MoreHorizontal } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function UsersTable({ users }: { users: User[] }) {
  return (
    <Table>
      <TableCaption>A list of all users</TableCaption>
      <TableHeader>
        <TableRow>
          <TableHead>Name</TableHead>
          <TableHead>Email</TableHead>
          <TableHead>Role</TableHead>
          <TableHead>Status</TableHead>
          <TableHead className="text-right">Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {users.map((user) => (
          <TableRow key={user._id}>
            <TableCell className="font-medium">{user.name}</TableCell>
            <TableCell>{user.email}</TableCell>
            <TableCell>
              <Badge variant="outline">{user.role}</Badge>
            </TableCell>
            <TableCell>
              <Badge variant={user.active ? "default" : "secondary"}>
                {user.active ? "Active" : "Inactive"}
              </Badge>
            </TableCell>
            <TableCell className="text-right">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon">
                    <MoreHorizontal className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem>Edit</DropdownMenuItem>
                  <DropdownMenuItem>View Details</DropdownMenuItem>
                  <DropdownMenuItem className="text-destructive">
                    Delete
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

### Tabs Pattern

```typescript
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export function ProfileTabs() {
  return (
    <Tabs defaultValue="overview" className="w-full">
      <TabsList className="grid w-full grid-cols-3">
        <TabsTrigger value="overview">Overview</TabsTrigger>
        <TabsTrigger value="activity">Activity</TabsTrigger>
        <TabsTrigger value="settings">Settings</TabsTrigger>
      </TabsList>

      <TabsContent value="overview">
        <Card>
          <CardHeader>
            <CardTitle>Overview</CardTitle>
            <CardDescription>Your account overview</CardDescription>
          </CardHeader>
          <CardContent>
            {/* Overview content */}
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="activity">
        <Card>
          <CardHeader>
            <CardTitle>Activity</CardTitle>
            <CardDescription>Recent activity on your account</CardDescription>
          </CardHeader>
          <CardContent>
            {/* Activity content */}
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="settings">
        <Card>
          <CardHeader>
            <CardTitle>Settings</CardTitle>
            <CardDescription>Manage your account settings</CardDescription>
          </CardHeader>
          <CardContent>
            {/* Settings content */}
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  );
}
```

## Advanced Patterns

### Skeleton Loading States

```typescript
import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent, CardHeader } from "@/components/ui/card";

export function PostCardSkeleton() {
  return (
    <Card>
      <CardHeader>
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-3 w-1/2 mt-2" />
      </CardHeader>
      <CardContent>
        <Skeleton className="h-20 w-full" />
      </CardContent>
    </Card>
  );
}

export function PostsListSkeleton() {
  return (
    <div className="space-y-4">
      {[...Array(3)].map((_, i) => (
        <PostCardSkeleton key={i} />
      ))}
    </div>
  );
}
```

### Toast Notifications

```typescript
import { useToast } from "@/components/ui/use-toast";
import { Button } from "@/components/ui/button";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function DeleteButton({ itemId }: { itemId: Id<"items"> }) {
  const { toast } = useToast();
  const deleteItem = useMutation(api.items.delete);

  const handleDelete = async () => {
    try {
      await deleteItem({ id: itemId });
      toast({
        title: "Success",
        description: "Item deleted successfully",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to delete item",
        variant: "destructive",
      });
    }
  };

  return (
    <Button variant="destructive" onClick={handleDelete}>
      Delete
    </Button>
  );
}
```

### Dropdown Menu with Actions

```typescript
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { MoreVertical, Edit, Trash, Copy, Archive } from "lucide-react";

export function ItemActions({ item }: { item: Item }) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuLabel>Actions</DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem>
          <Edit className="mr-2 h-4 w-4" />
          Edit
        </DropdownMenuItem>
        <DropdownMenuItem>
          <Copy className="mr-2 h-4 w-4" />
          Duplicate
        </DropdownMenuItem>
        <DropdownMenuItem>
          <Archive className="mr-2 h-4 w-4" />
          Archive
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem className="text-destructive">
          <Trash className="mr-2 h-4 w-4" />
          Delete
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

## Data Fetching with shadcn/ui

### List with Loading and Empty States

```typescript
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { FileX } from "lucide-react";

export function PostsList() {
  const posts = useQuery(api.posts.list);

  // Loading state
  if (posts === undefined) {
    return (
      <div className="space-y-4">
        {[...Array(3)].map((_, i) => (
          <Card key={i} className="p-6">
            <Skeleton className="h-4 w-3/4 mb-2" />
            <Skeleton className="h-3 w-1/2 mb-4" />
            <Skeleton className="h-20 w-full" />
          </Card>
        ))}
      </div>
    );
  }

  // Empty state
  if (posts.length === 0) {
    return (
      <Card className="p-12">
        <div className="flex flex-col items-center justify-center text-center">
          <FileX className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-semibold mb-2">No posts yet</h3>
          <p className="text-sm text-muted-foreground mb-4">
            Get started by creating your first post.
          </p>
          <Button>Create Post</Button>
        </div>
      </Card>
    );
  }

  // Success state
  return (
    <div className="space-y-4">
      {posts.map(post => (
        <PostCard key={post._id} post={post} />
      ))}
    </div>
  );
}
```

### Search with Debounce

```typescript
"use client";

import { useState } from "react";
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";
import { useDebounce } from "@/hooks/useDebounce";

export function SearchPosts() {
  const [search, setSearch] = useState("");
  const debouncedSearch = useDebounce(search, 300);

  const results = useQuery(
    api.posts.search,
    debouncedSearch ? { query: debouncedSearch } : "skip"
  );

  return (
    <div className="space-y-4">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search posts..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-10"
        />
      </div>

      {debouncedSearch && results && (
        <div className="space-y-2">
          {results.length === 0 ? (
            <p className="text-sm text-muted-foreground text-center py-8">
              No results found for "{debouncedSearch}"
            </p>
          ) : (
            results.map(post => (
              <Card key={post._id} className="p-4">
                <h3 className="font-semibold">{post.title}</h3>
                <p className="text-sm text-muted-foreground">{post.excerpt}</p>
              </Card>
            ))
          )}
        </div>
      )}
    </div>
  );
}
```

## Best Practices

1. **Always use shadcn/ui components** instead of building custom ones
2. **Customize through className** prop when needed
3. **Use Radix UI primitives** for complex interactions (shadcn is built on Radix)
4. **Follow shadcn naming conventions** for consistency
5. **Use lucide-react** for icons (official shadcn icon library)
6. **Leverage composition** - combine simple components to build complex UIs
7. **Use Skeleton components** for loading states instead of spinners
8. **Toast for notifications** instead of alerts or modals for simple feedback
